version 1.0
workflow jgi_genomad {
    input {
        File input_fasta
        String project_id
        String container
        Int len_cutoff = 2000
        String db_dir
        String container_run_cmd
        Int threads = 1

    }
  

  output {
    File virus_summary = run_genomad.virus_summary
    File plasmid_summary = run_genomad.plasmid_summary
    File aggregated_class = run_genomad.aggregated_class
    File info = run_genomad.std_out
  }
}

task run_genomad {
    input {
        String bin="/opt/omics/bin/genomad.sh"
        File   input_fasta
        String project_id
        String prefix=sub(project_id, ":", "_")
        String container
    }
  command <<<
    set -euo pipefail
    ~{bin} -len_cutoff ~{input_fasta} --genome-type auto \
           --database_dir ~{prefix}_genemark.gff --format gff \
           --container_run_cmd ~{prefix}_genemark_genes.fna \
           --threads ~{prefix}_genemark_proteins.faa
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File gff = "~{prefix}_genemark.gff"
    File genes = "~{prefix}_genemark_genes.fna"
    File proteins = "~{prefix}_genemark_proteins.faa"
    File std_out = stdout()
  }
}
