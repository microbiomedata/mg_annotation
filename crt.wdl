version 1.0
workflow crt {
    input {
        File imgap_input_fasta
        String imgap_project_id
        String container
    }
  call run {
    input:
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
	  container=container
  }

  output {
    File crisprs = run.crisprs
    File gff = run.gff
    File crt_out = run.crt_out
  }
}

task run {
    input {
        String jar="java -Xmx1536m -jar /opt/omics/bin/CRT-CLI.jar"
        String transform_bin="/opt/omics/bin/structural_annotation/transform_crt_output.py"
        File   input_fasta
        String project_id
        String prefix=sub(project_id, ":", "_")
        String container
    }
  command <<<
    ~{jar} ~{input_fasta} ~{prefix}_crt.out
    set -uo pipefail  # java returns error code 1 even apon success so remove set -e
    tool_and_version=$(~{jar} -version | cut -d' ' -f1,6)
    ~{transform_bin} ~{prefix}_crt.out "$tool_and_version"
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File crisprs = "~{prefix}_crt.crisprs"
    File gff = "~{prefix}_crt.gff"
    File crt_out = "~{prefix}_crt.out"
    File crisprs = "~{prefix}_crt.crisprs"
    File gff = "~{prefix}_crt.gff"
    File crt_out = "~{prefix}_crt.out"
  }
}

