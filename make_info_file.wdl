version 1.0

workflow make_info_file {
    input {
        String        container
        String        imgap_version
        File          map_info
        File          gen_info
        Boolean       fa_execute
        Boolean       sa_execute
        Boolean       genomad_execute
        String        imgap_project_id
        Array[String] rfam_version
        File          structural_gff
        Array[String] lastal_version
        Array[String] img_nr_db_version
        Array[String] hmmsearch_smart_version
        Array[String] smart_db_version
        Array[String] hmmsearch_cog_version
        Array[String] cog_db_version
        Array[String] hmmsearch_tigrfam_version
        Array[String] tigrfam_db_version
        Array[String] hmmsearch_superfam_version
        Array[String] superfam_db_version
        Array[String] hmmsearch_pfam_version
        Array[String] pfam_db_version
        Array[String] hmmsearch_cath_funfam_version
        Array[String] cath_funfam_db_version
    }

  call run {
    input:
      container = container,
      imgap_version = imgap_version,
      map_info = map_info,
      gen_info = gen_info,
      fa_execute = fa_execute,
      sa_execute = sa_execute,
      genomad_execute = genomad_execute,
      project_id = imgap_project_id,
      rfam_version = rfam_version,
      structural_gff = structural_gff,
      lastal_version = lastal_version,
      img_nr_db_version = img_nr_db_version,
      hmmsearch_smart_version = hmmsearch_smart_version,
      smart_db_version = smart_db_version,
      hmmsearch_cog_version = hmmsearch_cog_version,
      cog_db_version = cog_db_version,
      hmmsearch_tigrfam_version = hmmsearch_tigrfam_version,
      tigrfam_db_version = tigrfam_db_version,
      hmmsearch_superfam_version = hmmsearch_superfam_version,
      superfam_db_version = superfam_db_version,
      hmmsearch_pfam_version = hmmsearch_pfam_version,
      pfam_db_version = pfam_db_version,
      hmmsearch_cath_funfam_version = hmmsearch_cath_funfam_version,
      cath_funfam_db_version = cath_funfam_db_version
  }

  output {
    File imgap_info = run.imgap_info
  }
}

task run {
    input {
        String        container
        String        imgap_version
        File          map_info
        File          gen_info
        Boolean       fa_execute
        Boolean       sa_execute
        Boolean       genomad_execute
        String        project_id
        String        prefix=sub(project_id, ":", "_")
        Array[String] rfam_version
        Boolean       rfam_executed = if (defined(rfam_version)) then true else false
        File          structural_gff
        Array[String] lastal_version
        Array[String] img_nr_db_version
        Array[String] hmmsearch_smart_version
        Array[String] smart_db_version
        Array[String] hmmsearch_cog_version
        Array[String] cog_db_version
        Array[String] hmmsearch_tigrfam_version
        Array[String] tigrfam_db_version
        Array[String] hmmsearch_superfam_version
        Array[String] superfam_db_version
        Array[String] hmmsearch_pfam_version
        Array[String] pfam_db_version
        Array[String] hmmsearch_cath_funfam_version
        Array[String] cath_funfam_db_version
        String        fa_version_file = "fa_tool_version.txt"
        String        fa_db_version_file = "fa_db_version.txt"
        String        rfam_version_file = "rfam_version.txt"
    }
  command <<<
    set -euo pipefail
     echo "IMGAP Version: ~{imgap_version}" > ~{prefix}_imgap.info
     #get map script version

     map_version=`grep "fasta_sanity.py" ~{map_info}`
     map_version="Mapping Programs Used: $map_version"
     echo $map_version >> ~{prefix}_imgap.info

     #get structual annotation versions
     if [[ "~{sa_execute}" = true ]]
       then
       sa_version=`cut -f2 ~{structural_gff}  | sort | uniq | perl -pe 's/\n/; /g' | sed -E 's/(.*)\; /\1/'`
       sa_version="Structural Annotation Programs Used: $sa_version"
       echo $sa_version >> ~{prefix}_imgap.info
       if [[ "~{rfam_executed}" = true ]]
         then
         echo ~{sep="," rfam_version} > ~{rfam_version_file}
         cat  ~{rfam_version_file} | tr ',' '\n' | sort | uniq  > rfam_version_uniq.txt

         rfam_db_version="Structural Annotation DBs Used:"
   #use while instead of for to handle the spaces in values
         while read db_version ; do
           rfam_db_version="$rfam_db_version $db_version; "
         done < rfam_version_uniq.txt
         rfam_db_version=`echo $rfam_db_version | sed -E 's/(.*)\;/\1/'`
         echo  $rfam_db_version  >> ~{prefix}_imgap.info
       fi
    fi
     #get functional annotation tool versions
     if [[ "~{fa_execute}" = true ]]
       then
       echo ~{sep="," lastal_version} > ~{fa_version_file}
       echo ~{sep="," hmmsearch_smart_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_cog_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_cog_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_tigrfam_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_superfam_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_pfam_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_cath_funfam_version} >> ~{fa_version_file}
       cat ~{fa_version_file} | tr ',' '\n' | sort | uniq  > fa_version_uniq.txt
       fa_tool_version="Functional Annotation Programs Used: "
       while read tool ; do
         fa_tool_version="$fa_tool_version $tool; "
       done < fa_version_uniq.txt
       fa_tool_version=`echo $fa_tool_version | sed -E 's/(.*)\;/\1/'`
       echo $fa_tool_version >> ~{prefix}_imgap.info
       #get functional annotation db versions
       echo ~{sep="," img_nr_db_version} > ~{fa_db_version_file}
       echo ~{sep="," smart_db_version} >> ~{fa_db_version_file}
       echo ~{sep="," cog_db_version} >> ~{fa_db_version_file}
       echo ~{sep="," tigrfam_db_version} >> ~{fa_db_version_file}
       echo ~{sep="," superfam_db_version} >> ~{fa_db_version_file}
       echo ~{sep="," pfam_db_version} >> ~{fa_db_version_file}
       echo ~{sep="," cath_funfam_db_version} >> ~{fa_db_version_file}
       cat ~{fa_db_version_file} | tr ',' '\n' | sort | uniq  > fa_db_version_uniq.txt
       fa_db_version="Functional Annotation DBs Used: "
       while read db ; do
         fa_db_version="$fa_db_version $db; "
       done < fa_db_version_uniq.txt
       fa_db_version=`echo $fa_db_version | sed -E 's/(.*)\;/\1/'`
       echo $fa_db_version >> ~{prefix}_imgap.info
    fi
    if [[ "~{genomad_execute}" = true ]]
      then
      g_prog=`grep "Programs" -A1 ~{gen_info} | tail -n 1`
      g_db=`grep "DBs" -A1 ~{gen_info} | tail -n 1`
      echo "geNomad Programs Used: $g_prog"  >> ~{prefix}_imgap.info
      echo "geNomad DBs Used: $g_db"  >> ~{prefix}_imgap.info
    fi
  >>>

  output {
    File imgap_info = "~{prefix}_imgap.info"
  }

  runtime {
    memory: "2G"
    cpu: 4
    maxRetries: 1
    docker: container
  }
}
