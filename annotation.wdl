version 1.0
import "structural-annotation.wdl" as sa
import "functional-annotation.wdl" as fa

workflow annotation {
  input {
    String   cmzscore
    File    imgap_input_fasta
    String  imgap_project_id="GaXXXXXXX_contigs.fna"
    String database_location="/refdata/img/"
    String  imgap_project_type="metagenome"
    Int     additional_threads=16
    
    # structural annotation
    Boolean sa_execute=true
    # functional annotation
    Boolean fa_execute=true  
    Int?    fa_approx_num_proteins
    File? gm_license
    }

  if(sa_execute) {
      call sa.s_annotate {
        input:
          imgap_input_fasta = imgap_input_fasta,
          imgap_project_id = imgap_project_id,
          additional_threads = additional_threads,
          imgap_project_type = imgap_project_type,
          cmzscore = cmzscore, 
          database_location = database_location,
          gm_license = gm_license
      }
    }

    if(fa_execute) {
      call fa.f_annotate {
        input:
          imgap_project_id = imgap_project_id,
          imgap_project_type = imgap_project_type,
          additional_threads = additional_threads,
          input_fasta = s_annotate.proteins,
          approx_num_proteins = fa_approx_num_proteins,
          database_location = database_location,
          sa_gff = s_annotate.gff
      }

  }
}
