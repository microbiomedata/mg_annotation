version 1.0

workflow fasta_merge {
    input {
        String imgap_project_id
        File   final_gff
        File   cds_genes
        File   cds_proteins
        String container
    }

  call run {
    input:
      project_id = imgap_project_id,
      final_gff = final_gff,
      cds_genes = cds_genes,
      cds_proteins = cds_proteins,
      container = container
  }

  output {
    File final_genes = run.final_genes
    File final_proteins = run.final_proteins
  }
}

task run {
    input {
        String bin="/opt/omics/bin/structural_annotation/finalize_fasta_files.py"
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   final_gff
        File   cds_genes
        File   cds_proteins
        String genes_filename = basename(cds_genes)
        String proteins_filename = basename(cds_proteins)
        String container
    }
  command <<<
    set -euo pipefail
    cp ~{final_gff} .
    cp ~{cds_genes} .
    cp ~{cds_proteins} .
    ~{bin} ~{final_gff} ~{genes_filename} ~{proteins_filename}
  >>>

  runtime {
    time: "2:00:00"
    memory: "40G"
    docker: container
  }

  output {
    File final_genes = "~{prefix}_genes.fna"
    File final_proteins = "~{prefix}_proteins.faa"
  }
}
