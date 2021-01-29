workflow crt {

  String imgap_input_fasta
  String imgap_project_id

  call run {
    input:
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id
  }

  call transform {
    input:
      project_id = imgap_project_id,
      crt_out = run.out
  }

  output {
    File crisprs = transform.crisprs
    File gff = transform.gff
  }
}

task run {

  String jar="java -Xmx1536m -jar /opt/omics/bin/CRT-CLI.jar"
  File   input_fasta
  String project_id

  command {
    #java -Xmx1536m -jar ${jar} ${input_fasta} ${project_id}_crt.out
    ${jar} ${input_fasta} ${project_id}_crt.out
  }

  runtime {
    time: "1:00:00"
    memory: "86G"
  }

  output {
    File out = "${project_id}_crt.out"
  }
}

task transform {

  String jar="java -Xmx1536m -jar /opt/omics/bin/CRT-CLI.jar"
  String transform_bin="/opt/omics/bin/structural_annotation/transform_crt_output.py"
  File   crt_out
  String project_id
  String crt_out_local = basename(crt_out)

  command {
    mv ${crt_out} ./${crt_out_local}
    tool_and_version=$(${jar} -version | cut -d' ' -f1,6)
    ${transform_bin} ${crt_out_local} "$tool_and_version"
  }

  runtime {
    time: "1:00:00"
    memory: "86G"
  }

  output{
    File crisprs = "${project_id}_crt.crisprs"
    File gff = "${project_id}_crt.gff"
  }
}

