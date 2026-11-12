version 1.0

workflow gff_and_fasta_stats {
    input {
        File   imgap_input_fasta
        String imgap_project_id
        File   final_gff
        String container
    }

  call run {
    input:
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
      final_gff = final_gff,
      container = container
  }

  output {
    File tsv = run.tsv
    File json = run.json
  }
}

task run {
    input {
        String bin="/opt/omics/bin/structural_annotation/gff_and_final_fasta_stats.py"
        File   input_fasta
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   final_gff
        String container
    }
  command <<<
    set -euo pipefail
    ln ~{input_fasta} ~{prefix}_contigs.fna || ln -s ~{input_fasta} ~{prefix}_contigs.fna
    ~{bin} ~{prefix}_contigs.fna ~{final_gff}
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File tsv = "~{prefix}_structural_annotation_stats.tsv"
    File json = "~{prefix}_structural_annotation_stats.json"
  }
}
