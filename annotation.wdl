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
    
    Int?    fa_approx_num_proteins
    File? gm_license
    }

  
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
  output{
    File  sa_gff = s_annotate.gff
    File? crt_gff = s_annotate.crt_gff
    File? crisprs = s_annotate.crisprs 
    File? crt_out = s_annotate.crt_out
    File? genemark_gff = s_annotate.genemark_gff
    File? genemark_genes = s_annotate.genemark_genes
    File? genemark_proteins = s_annotate.genemark_proteins 
    File? prodigal_gff = s_annotate.prodigal_gff
    File? prodigal_genes = s_annotate.prodigal_genes
    File? prodigal_proteins = s_annotate.prodigal_proteins
    File? cds_gff = s_annotate.cds_gff
    File? cds_proteins = s_annotate.cds_proteins
    File? cds_genes = s_annotate.cds_genes
    File? trna_gff = s_annotate.trna_gff
    File? trna_bacterial_out = s_annotate.trna_bacterial_out
    File? trna_archaeal_out = s_annotate.trna_archaeal_out
    File? rfam_gff = s_annotate.rfam_gff
    File? rfam_tbl = s_annotate.rfam_tbl
    File? proteins = s_annotate.proteins
    File? genes = s_annotate.genes
    File product_name_gff = f_annotate.gff
    File product_name_tsv = f_annotate.product_name_tsv
    File ko_tsv = f_annotate.ko_tsv
    File ec_tsv = f_annotate.ec_tsv
    File phylo_tsv = f_annotate.phylo_tsv
    File ko_ec_gff = f_annotate.ko_ec_gff
    File last_blasttab = f_annotate.last_blasttab
    File lineage_tsv = f_annotate.lineage_tsv
    File cog_gff = f_annotate.cog_gff
    File pfam_gff = f_annotate.pfam_gff
    File tigrfam_gff = f_annotate.tigrfam_gff
    File supfam_gff = f_annotate.supfam_gff
    File smart_gff = f_annotate.smart_gff
    File cath_funfam_gff = f_annotate.cath_funfam_gff
    File cog_domtblout = f_annotate.cog_domtblout
    File pfam_domtblout = f_annotate.pfam_domtblout
    File tigrfam_domtblout = f_annotate.tigrfam_domtblout
    File supfam_domtblout = f_annotate.supfam_domtblout
    File smart_domtblout = f_annotate.smart_domtblout
    File cath_funfam_domtblout = f_annotate.cath_funfam_domtblout
  }
}
