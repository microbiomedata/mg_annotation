version 1.0

workflow post_qc {
    input {
        File   imgap_input_fasta
        File   structural_gff
        String imgap_project_id
        String container
    }

  call run {
    input:
      input_fasta = imgap_input_fasta,
      structural_gff = structural_gff,
      project_id = imgap_project_id,
      container = container
  }

  output {
    File out = run.out
  }
}

task run {
    input {
        String qc_bin="/opt/omics/bin/qc/post-annotation/genome_structural_annotation_sanity.py"
        File   input_fasta
        File   structural_gff
        String project_id
        String prefix=sub(project_id, ":", "_")
        String container
    }
  command <<<
    set -euo pipefail
    cp ~{structural_gff} "~{prefix}_structural_annotation.gff"
    ~{qc_bin} ~{input_fasta} "~{prefix}_structural_annotation.gff"
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File out = "~{prefix}_structural_annotation.gff"
  }
}
