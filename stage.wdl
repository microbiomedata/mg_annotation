version 1.0

workflow stage {
    input {
        String container
        String target="input.fasta"
        String input_file
    }

  call run {
    input:
      container = container,
      target = target,
      input_file = input_file
  }

  output {
    File   imgap_input_fasta = run.imgap_input_fasta
    String start = run.start
  }
}

task run {
    input {
        String container
        String target="input.fasta"
        File   input_file
    }

  command <<<
    set -eou pipefail
    if [ $( echo ~{input_file}|egrep -c "https*:") -gt 0 ] ; then
        wget ~{input_file} -O ~{target}
    else
        ln ~{input_file} ~{target} || ln -s ~{input_file} ~{target}
    fi
    # Capture the start time
    date --iso-8601=seconds > start.txt
  >>>

  output {
    File   imgap_input_fasta = "~{target}"
    String start = read_string("start.txt")
  }

  runtime {
    memory: "1G"
    cpu: 2
    maxRetries: 1
    docker: container
  }
}
