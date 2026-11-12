version 1.0

workflow tmhmm {
    input {
        String imgap_project_id
        File   input_fasta
        String model="/opt/omics/programs/tmhmm-2.0c/lib/TMHMM2.0.model"
        String decode="/opt/omics/bin/decodeanhmm"
        String decode_parser="/opt/omics/bin/functional_annotation/decodeanhmm_parser.py"
        String container
    }

  call run {
    input:
      project_id = imgap_project_id,
      input_fasta = input_fasta,
      model = model,
      decode = decode,
      decode_parser = decode_parser,
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
        String model
        String decode
        String decode_parser
        String container
    }
  command <<<
    set -euo pipefail
    tool_and_version=$(~{decode} -v 2>&1 | head -1)
    background="0.081 0.015 0.054 0.061 0.040 0.068 0.022 0.057 0.056 0.093 0.025"
    background="$background 0.045 0.049 0.039 0.057 0.068 0.058 0.067 0.013 0.032"
    sed 's/\*/X/g' ~{input_fasta} | \
    ~{decode} -N 1 -background $background -PrintNumbers \
    ~{model} 2> /dev/null | ~{decode_parser} "$tool_and_version" > ~{prefix}_tmh.gff
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File gff = "~{prefix}_tmh.gff"
  }
}
