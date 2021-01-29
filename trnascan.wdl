workflow trnascan {

  String imgap_input_fasta
  String imgap_project_id
  String imgap_project_type
  Int    additional_threads

  call trnascan_ba {
    input:
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
      threads = additional_threads,
  }
  call pick_and_transform_to_gff {
    input:
      project_id = imgap_project_id,
      bacterial_out = trnascan_ba.bacterial_out,
      archaeal_out = trnascan_ba.archaeal_out
  }
  output {
    File gff = pick_and_transform_to_gff.gff
  }
}

task trnascan_ba {

  String bin="/opt/omics/bin/tRNAscan-SE"
  File input_fasta
  String project_id
  Int    threads
  String dollar="$"
  command <<<
     base=${dollar}(basename ${input_fasta})
     cp ${input_fasta} ./${project_id}_contigs.fna
     /opt/omics/bin/structural_annotation/trnascan-se_trnas.sh ${project_id}_contigs.fna metagenome ${threads}
  >>>

#  command {
#    ${bin} -B --thread ${threads} ${input_fasta} &> ${project_id}_trnascan_bacterial.out
#    ${bin} -A --thread ${threads} ${input_fasta} &> ${project_id}_trnascan_archaeal.out
#  }

runtime {
    time: "1:00:00"
    memory: "86G"
  }

  output {
    File bacterial_out = "${project_id}_trnascan_bacterial.out"
    File archaeal_out = "${project_id}_trnascan_archaeal.out"
  }
}

task pick_and_transform_to_gff {

  String bin="/opt/omics/bin/structural_annotation/trna_pick_and_transform_to_gff.py"
  String project_id
  File   bacterial_out
  File   archaeal_out
  
  command {
    ${bin} ${bacterial_out} ${archaeal_out} > ${project_id}_trna.gff
  }

  runtime {
    time: "1:00:00"
    memory: "86G"
  }

  output {
    File gff = "${project_id}_trna.gff"
  }
}
