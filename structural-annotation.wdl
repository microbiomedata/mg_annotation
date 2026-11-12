version 1.0

import "trnascan.wdl" as trnascan
import "rfam.wdl" as rfam
import "crt.wdl" as crt
import "cds_prediction.wdl" as cds_prediction
import "gff_merge.wdl" as gff_merge
import "fasta_merge.wdl" as fasta_merge
import "gff_and_fasta_stats.wdl" as gff_and_fasta_stats

workflow s_annotate {
    input {
      String  cmzscore
      File    imgap_input_fasta
      String  imgap_project_id
      String  imgap_project_type
      Int     additional_threads
      Int     additional_memory
      Int?    imgap_structural_annotation_translation_table
      String  database_location
      String  container
      String  gm_license="/refdata/licenses/.gmhmmp2_key"
    }

    call trnascan.trnascan as ts {
      input:
        imgap_input_fasta = imgap_input_fasta,
        imgap_project_id = imgap_project_id,
        additional_threads = additional_threads,
        container = container
    }

    call rfam.rfam as rf {
      input:
        cmzscore = cmzscore,
        imgap_input_fasta = imgap_input_fasta,
        imgap_project_id = imgap_project_id,
        database_location = database_location,
        additional_threads = additional_threads,
        container = container,
        additional_memory = additional_memory
    }

    call crt.crt as ct {
      input:
        imgap_input_fasta = imgap_input_fasta,
        imgap_project_id = imgap_project_id,
        container = container
    }

    call cds_prediction.cds_prediction as cds {
      input:
        imgap_input_fasta = imgap_input_fasta,
        imgap_project_id = imgap_project_id,
        imgap_project_type = imgap_project_type,
        imgap_structural_annotation_translation_table = imgap_structural_annotation_translation_table,
        container = container,
        gm_license = gm_license
    }

    call gff_merge.gff_merge as gm {
      input:
        imgap_input_fasta = imgap_input_fasta,
        imgap_project_id = imgap_project_id,
        rfam_gff = rf.rfam_gff,
        trna_gff = ts.gff,
        crt_gff = ct.gff,
        cds_gff = cds.gff,
        container = container
    }

    call fasta_merge.fasta_merge as fm {
      input:
        imgap_project_id = imgap_project_id,
        final_gff = gm.final_gff,
        cds_genes = cds.genes,
        cds_proteins = cds.proteins,
        container = container
    }

    call gff_and_fasta_stats.gff_and_fasta_stats as gfs {
      input:
        imgap_input_fasta = imgap_input_fasta,
        imgap_project_id = imgap_project_id,
        final_gff = gm.final_gff,
        container = container
    }

  output {
    File   gff = gm.final_gff
    File   crt_gff = ct.gff
    File   crisprs = ct.crisprs
    File   crt_out = ct.crt_out
    File   genemark_gff = cds.genemark_gff
    File   genemark_genes = cds.genemark_genes
    File   genemark_proteins = cds.genemark_proteins
    File   prodigal_gff = cds.prodigal_gff
    File   prodigal_genes = cds.prodigal_genes
    File   prodigal_proteins = cds.prodigal_proteins
    File   cds_gff = cds.gff
    File   cds_proteins = cds.proteins
    File   cds_genes = cds.genes
    File   trna_gff = ts.gff
    File   trna_bacterial_out = ts.bacterial_out
    File   trna_archaeal_out = ts.archaeal_out
    File   rfam_gff = rf.rfam_gff
    File   rfam_tbl = rf.rfam_tbl
    String rfam_version = rf.rfam_version
    File   proteins = fm.final_proteins
    File   genes = fm.final_genes
    File   stats_tsv = gfs.tsv
    File   stats_json = gfs.json
  }
}
