version 1.0

workflow gff_merge {
    input {
        File   imgap_input_fasta
        String imgap_project_id
        File   trna_gff
        File   rfam_gff
        File   crt_gff
        File   cds_gff
        String container
    }

  call run {
    input:
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
      trna_gff = trna_gff,
      rfam_gff = rfam_gff,
      crt_gff = crt_gff,
      cds_gff = cds_gff,
      container = container
  }

  output {
    File final_gff = run.final_gff
  }
}

task run {
    input {
        String bin="/opt/omics/bin/structural_annotation/gff_files_merger.py"
        File   input_fasta
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   trna_gff
        File   rfam_gff
        File   crt_gff
        File   cds_gff
        String container
    }
  command <<<
    set -euo pipefail

    ~{bin} \
      --contigs_fasta ~{input_fasta} \
      --cds_gff ~{cds_gff} \
      --crt_gff ~{crt_gff} \
      --log_file ~{prefix}_gff_merge.log \
      ~{rfam_gff} \
      ~{trna_gff} \
     1> ~{prefix}_structural_annotation.gff
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File final_gff = "~{prefix}_structural_annotation.gff"
  }
}
