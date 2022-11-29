import "structural-annotation.wdl" as sa
import "functional-annotation.wdl" as fa

workflow annotation {
  File?   zscore_file
  File    imgap_input_fasta
  String  imgap_project_id="GaXXXXXXX_contigs.fna"
  String database_location="/cromwell_root/database"
  String  imgap_project_type="metagenome"
  Int     additional_threads=16

  # structural annotation
  Boolean sa_execute=true
  # functional annotation
  Boolean fa_execute=true

  Int?    fa_approx_num_proteins

  if(sa_execute) {
      call sa.s_annotate {
        input:
          imgap_input_fasta = imgap_input_fasta,
          imgap_project_id = imgap_project_id,
          additional_threads = additional_threads,
          imgap_project_type = imgap_project_type,
          database_location = database_location
      }
    }

    if(fa_execute) {
      call fa.f_annotate {
        input:
	  zscore_file = zscore_file,
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
