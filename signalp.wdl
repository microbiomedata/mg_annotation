version 1.0

workflow signalp {
    input {
        String imgap_project_id
        File   input_fasta
        String gram_stain
        String signalp_bin="/opt/omics/bin/signalp"
        String container
    }

  call run {
    input:
      project_id = imgap_project_id,
      input_fasta = input_fasta,
      gram_stain = gram_stain,
      signalp = signalp_bin,
      container = container
  }

  output {
    File gff = run.gff
  }
}

task run {
    input {
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   input_fasta
        String gram_stain
        String signalp
        String container
    }
  command <<<
    set -euo pipefail
    signalp_version=$(~{signalp} -V)
    ~{signalp} -t ~{gram_stain} -f short ~{input_fasta} | \
    grep -v '^#' | \
    awk -v sv="$signalp_version" -v ot="~{gram_stain}" \
        '$10 == "Y" {print $1"\t"sv"\tcleavage_site\t"$3-1"\t"$3"\t"$2\
        "\t.\t.\tD-score="$9";network="$12";organism_type="ot}' > ~{prefix}_cleavage_sites.gff
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File gff = "~{prefix}_cleavage_sites.gff"
  }
}
