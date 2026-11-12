version 1.0

import "ko_ec.wdl" as ko_ec
import "smart.wdl" as smart
import "cog.wdl" as cog
import "tigrfam.wdl" as tigrfam
import "superfam.wdl" as superfam
import "pfam.wdl" as pfam
import "cath_funfam.wdl" as cath_funfam
import "product_name.wdl" as product_name

workflow f_annotate {
    input {
        String  imgap_project_id
        String  imgap_project_type
        Int     additional_threads
        File    input_fasta
        String  database_location="/refdata/img/"
        Int?    par_hmm_inst
        Int?    approx_num_proteins
        File    sa_gff
        String  container
    }

    call ko_ec.ko_ec as ke {
      input:
        imgap_project_id = imgap_project_id,
        imgap_project_type = imgap_project_type,
        input_fasta = input_fasta,
        additional_threads = additional_threads,
        database_location = database_location,
        container = container
    }

    call smart.smart as sm {
      input:
        imgap_project_id = imgap_project_id,
        input_fasta = input_fasta,
        additional_threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        database_location = database_location,
        container = container
    }

    call cog.cog as cg {
      input:
        imgap_project_id = imgap_project_id,
        input_fasta = input_fasta,
        additional_threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        database_location = database_location,
        container = container
    }

    call tigrfam.tigrfam as tf {
      input:
        imgap_project_id = imgap_project_id,
        input_fasta = input_fasta,
        additional_threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        database_location = database_location,
        container = container
    }

    call superfam.superfam as sf {
      input:
        imgap_project_id = imgap_project_id,
        input_fasta = input_fasta,
        additional_threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        database_location = database_location,
        container = container
    }

    call pfam.pfam as pf {
      input:
        imgap_project_id = imgap_project_id,
        input_fasta = input_fasta,
        additional_threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        database_location = database_location,
        container = container
    }

    call cath_funfam.cath_funfam as cf {
      input:
        imgap_project_id = imgap_project_id,
        input_fasta = input_fasta,
        additional_threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = approx_num_proteins,
        database_location = database_location,
        container = container
    }

    call product_name.product_name as pn {
      input:
        imgap_project_id = imgap_project_id,
        sa_gff = sa_gff,
        database_location = database_location,
        ko_ec_gff = ke.gff,
        smart_gff = sm.gff,
        cog_gff = cg.gff,
        tigrfam_gff = tf.gff,
        supfam_gff = sf.gff,
        pfam_gff = pf.gff,
        cath_funfam_gff = cf.gff,
        container = container
    }

  output {
    File   gff = pn.gff
    File   product_name_tsv = pn.tsv
    File   ko_tsv = ke.ko_tsv
    File   ec_tsv = ke.ec_tsv
    File   phylo_tsv = ke.phylo_tsv
    File   ko_ec_gff = ke.gff
    File   last_blasttab = ke.last_blasttab
    File   lineage_tsv = ke.lineage_tsv
    File   cog_gff = cg.gff
    File   pfam_gff = pf.gff
    File   tigrfam_gff = tf.gff
    File   supfam_gff = sf.gff
    File   smart_gff = sm.gff
    File   cath_funfam_gff = cf.gff
    File   cog_domtblout = cg.domtblout
    File   pfam_domtblout = pf.domtblout
    File   tigrfam_domtblout = tf.domtblout
    File   supfam_domtblout = sf.domtblout
    File   smart_domtblout = sm.domtblout
    File   cath_funfam_domtblout = cf.domtblout
    String lastal_version = ke.lastal_ver
    String img_nr_db_version = ke.img_nr_db_ver
    String hmmsearch_smart_version = sm.hmmsearch_smart_ver
    String smart_db_version = sm.smart_db_ver
    String hmmsearch_cog_version = cg.hmmsearch_cog_ver
    String cog_db_version = cg.cog_db_ver
    String hmmsearch_tigrfam_version = tf.hmmsearch_tigrfam_ver
    String tigrfam_db_version = tf.tigrfam_db_ver
    String hmmsearch_superfam_version = sf.hmmsearch_superfam_ver
    String superfam_db_version = sf.superfam_db_ver
    String hmmsearch_pfam_version = pf.hmmsearch_pfam_ver
    String pfam_db_version = pf.pfam_db_ver
    String hmmsearch_cath_funfam_version = cf.hmmsearch_cath_funfam_ver
    String cath_funfam_db_version = cf.cath_funfam_db_ver
  }
}
