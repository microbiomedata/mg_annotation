version 1.0

workflow product_name {
    input {
        String imgap_project_id
        File   sa_gff
        String database_location="/refdata/img/"
        String product_assign_bin="/opt/omics/bin/functional_annotation/assign_product_names_and_create_fa_gff.py"
        String product_names_mapping_dir="~{database_location}"+"/Product_Name_Mappings/20250123"
        File   ko_ec_gff
        File   smart_gff
        File   cog_gff
        File   tigrfam_gff
        File   supfam_gff
        File   pfam_gff
        File   cath_funfam_gff
        String container
    }

  call run {
    input:
      project_id = imgap_project_id,
      sa_gff = sa_gff,
      product_assign = product_assign_bin,
      map_dir = product_names_mapping_dir,
      ko_ec_gff = ko_ec_gff,
      smart_gff = smart_gff,
      cog_gff = cog_gff,
      tigrfam_gff = tigrfam_gff,
      supfam_gff = supfam_gff,
      pfam_gff = pfam_gff,
      cath_funfam_gff = cath_funfam_gff,
      container = container
  }

  output {
    File gff = run.gff
    File tsv = run.tsv
  }
}

task run {
    input {
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   sa_gff
        String product_assign
        String map_dir
        File   ko_ec_gff
        File   smart_gff
        File   cog_gff
        File   tigrfam_gff
        File   supfam_gff
        File   pfam_gff
        File   cath_funfam_gff
        String container
    }
  command <<<
    set -euo pipefail
    ~{product_assign} ~{"-k " + ko_ec_gff} ~{"-s " + smart_gff} ~{"-c " + cog_gff} \
                      ~{"-t " + tigrfam_gff} ~{"-u " + supfam_gff} ~{"-p " + pfam_gff} \
                      ~{"-f " + cath_funfam_gff} \
                      ~{map_dir} ~{sa_gff}
    mv ../inputs/*/*.gff .
    mv ../inputs/*/*.tsv .
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File gff = "~{prefix}_functional_annotation.gff"
    File tsv = "~{prefix}_product_names.tsv"
  }
}
