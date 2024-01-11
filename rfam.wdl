workflow rfam {
  String cmzscore
  String imgap_input_fasta
  String imgap_project_id
  String imgap_project_type
  String database
  Boolean gcloud_env
  Int    additional_threads
  String database_location="/refdata/img/"
  String cm="${database_location}"+"Rfam/13.0_2020/Rfam.cm"
  String claninfo_tsv="${database_location}"+"Rfam/13.0_2020/Rfam.claninfo"
  String feature_lookup_tsv="${database_location}"+"Rfam/13.0_2020/Rfam_feature_lookup.tsv"
  String container
  

  call run {
    input:
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
      cm = cm,
      cmzscore=cmzscore,
      feature_lookup_tsv = feature_lookup_tsv,
      claninfo_tsv = claninfo_tsv,
      database = database,
      gcloud_env = gcloud_env,
      threads = additional_threads,
      container=container
  }

  output {
    File rfam_gff = run.rfam_gff
    File rfam_tbl = run.tbl
    String rfam_version = run.rfam_ver
  }
}

task run {

  String bin="/opt/omics/bin/cmsearch"
  String clan_filter_bin="/opt/omics/bin/structural_annotation/rfam_clan_filter.py"
  File   input_fasta
  File cm
  String project_id
  Boolean gcloud_env
  String database
  Array[File]? gcloud_db= if (gcloud_env) then [database] else []
  String db_path_img = "/cromwell_root/workflows_refdata/refdata/img/"
  String cmzscore
  String claninfo_tsv
  String feature_lookup_tsv
  Int    threads
  String container
  String rfam_version_file = "rfam_version.txt"

  command <<<
    set -euo pipefail
    if ${gcloud_env}; then
          dbdir=$(find /mnt -type d -name img)
          if [ -n $dbdir ]; then
              ln -s $dbdir ${db_path_img}
          else
              echo "Cannot find gcloud refdb" 1>&2
          fi
      fi
    
    ${bin} --notextw --cut_tc --cpu ${threads} -Z ${cmzscore} --tblout ${project_id}_rfam.tbl ${cm} ${input_fasta}
    tool_and_version=$(${bin} -h | grep INFERNAL | perl -pne 's/^.*INFERNAL/INFERNAL/' )
    if [ $(grep -c -v \# ${project_id}_rfam.tbl) -eq 0 ] ; then
        touch ${project_id}_rfam.gff
    else
        grep -v '^#' ${project_id}_rfam.tbl | \
            awk '$17 == "!" {print $1,$3,$4,$6,$7,$8,$9,$10,$11,$15,$16}' | \
            sort -k1,1 -k10,10nr -k11,11n | \
            ${clan_filter_bin} "$tool_and_version" \
            ${claninfo_tsv} ${feature_lookup_tsv} > ${project_id}_rfam.gff
    fi
 
  #get database version
  rfam_version=$(basename $(dirname ${cm}))
  echo "Rfam $rfam_version" > ${rfam_version_file}
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File tbl = "${project_id}_rfam.tbl"
    File rfam_gff = "${project_id}_rfam.gff"
    String rfam_ver = read_string(rfam_version_file)
  }
}
