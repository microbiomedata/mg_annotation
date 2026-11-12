version 1.0

import "structural-annotation.wdl" as sa
import "functional-annotation.wdl" as fa
import "genomad.wdl" as ge
import "stage.wdl" as stage
import "make_map_file.wdl" as make_map_file
import "split.wdl" as split
import "merge_outputs.wdl" as merge_outputs
import "make_info_file.wdl" as make_info_file
import "gff_and_fasta_stats.wdl" as gff_and_fasta_stats
import "finish_ano.wdl" as finish_ano

workflow annotation {
  input {
    String  proj
    String  input_file
    String  imgap_project_id
    String  database_location="/refdata/img/"
    String  imgap_project_type="metagenome"
    String  gm_license="/refdata/licenses/.gmhmmp2_key"
    Int     additional_threads=16
    Int     additional_memory = 100
    Int     split_blocksize = 100
    String  container = "ghcr.io/microbiomedata/nmdc-img-annotation-pipeline@sha256:16fb1aab91eb490276e7dd4c453f30dea46cfc3d1a94932364f434f3fd8b6333"
    String  genomad_db_dir = "/refdata/genomad_db/"
    # structural annotation
    Boolean sa_execute=true

    # functional annotation
    Boolean fa_execute=true

    Boolean genomad_execute = true
  }

  call stage.stage as stg {
    input:
      container = container,
      input_file = input_file
  }

  call make_map_file.make_map_file as mmf {
    input:
      proj_id = proj,
      input_file = stg.imgap_input_fasta,
      container = container
  }

  call split.split as sp {
    input:
      infile = mmf.out_fasta,
      blocksize = split_blocksize,
      container = container
  }

  scatter(pathname in sp.files) {
    call sa.s_annotate {
      input:
        cmzscore = sp.cmzscore,
        imgap_input_fasta = pathname,
        imgap_project_id = imgap_project_id,
        additional_threads = additional_threads,
        imgap_project_type = imgap_project_type,
        database_location = database_location,
        container = container,
        gm_license = gm_license,
        additional_memory = additional_memory
    }

    call fa.f_annotate {
      input:
        approx_num_proteins = sp.zscore,
        imgap_project_id = imgap_project_id,
        imgap_project_type = imgap_project_type,
        additional_threads = additional_threads,
        input_fasta = s_annotate.proteins,
        database_location = database_location,
        sa_gff = s_annotate.gff,
        container = container
    }

    call ge.jgi_genomad {
      input:
        genomad_execute = genomad_execute,
        input_fasta = pathname,
        db_dir = genomad_db_dir,
        container = container
    }
  }

  call merge_outputs.merge_outputs as mo {
    input:
      imgap_project_id = imgap_project_id,
      product_name_tsvs = f_annotate.product_name_tsv,
      structural_gffs = s_annotate.gff,
      functional_gffs = f_annotate.gff,
      ko_tsvs = f_annotate.ko_tsv,
      ec_tsvs = f_annotate.ec_tsv,
      phylo_tsvs = f_annotate.phylo_tsv,
      last_blasttabs = f_annotate.last_blasttab,
      lineage_tsvs = f_annotate.lineage_tsv,
      proteins = s_annotate.proteins,
      genes = s_annotate.genes,
      ko_ec_gffs = f_annotate.ko_ec_gff,
      cog_gffs = f_annotate.cog_gff,
      pfam_gffs = f_annotate.pfam_gff,
      tigrfam_gffs = f_annotate.tigrfam_gff,
      smart_gffs = f_annotate.smart_gff,
      supfam_gffs = f_annotate.supfam_gff,
      cath_funfam_gffs = f_annotate.cath_funfam_gff,
      cog_domtblouts = f_annotate.cog_domtblout,
      pfam_domtblouts = f_annotate.pfam_domtblout,
      tigrfam_domtblouts = f_annotate.tigrfam_domtblout,
      smart_domtblouts = f_annotate.smart_domtblout,
      supfam_domtblouts = f_annotate.supfam_domtblout,
      cath_funfam_domtblouts = f_annotate.cath_funfam_domtblout,
      crt_crisprs_s = s_annotate.crisprs,
      crt_outs = s_annotate.crt_out,
      crt_gffs = s_annotate.crt_gff,
      genemark_gffs = s_annotate.genemark_gff,
      genemark_genes = s_annotate.genemark_genes,
      genemark_proteins = s_annotate.genemark_proteins,
      prodigal_gffs = s_annotate.prodigal_gff,
      prodigal_genes = s_annotate.prodigal_genes,
      prodigal_proteins = s_annotate.prodigal_proteins,
      cds_gffs = s_annotate.cds_gff,
      cds_genes = s_annotate.cds_genes,
      cds_proteins = s_annotate.cds_proteins,
      trna_gffs = s_annotate.trna_gff,
      trna_bacterial_outs = s_annotate.trna_bacterial_out,
      trna_archaeal_outs = s_annotate.trna_archaeal_out,
      rfam_gffs = s_annotate.rfam_gff,
      rfam_tbls = s_annotate.rfam_tbl,
      virus_summary = jgi_genomad.virus_summary,
      plasmid_summary = jgi_genomad.plasmid_summary,
      aggregated_class = jgi_genomad.aggregated_class,
      container = container
  }

  call make_info_file.make_info_file as mif {
    input:
      imgap_project_id = imgap_project_id,
      container = container,
      sa_execute = sa_execute,
      fa_execute = fa_execute,
      map_info = mmf.out_log,
      gen_info = jgi_genomad.info[0],
      genomad_execute = genomad_execute,
      structural_gff = mo.structural_gff,
      imgap_version = sp.imgap_version,
      rfam_version = s_annotate.rfam_version,
      lastal_version = f_annotate.lastal_version,
      img_nr_db_version = f_annotate.img_nr_db_version,
      hmmsearch_smart_version = f_annotate.hmmsearch_smart_version,
      smart_db_version = f_annotate.smart_db_version,
      hmmsearch_cog_version = f_annotate.hmmsearch_cog_version,
      cog_db_version = f_annotate.cog_db_version,
      hmmsearch_tigrfam_version = f_annotate.hmmsearch_tigrfam_version,
      tigrfam_db_version = f_annotate.tigrfam_db_version,
      hmmsearch_superfam_version = f_annotate.hmmsearch_superfam_version,
      superfam_db_version = f_annotate.superfam_db_version,
      hmmsearch_pfam_version = f_annotate.hmmsearch_pfam_version,
      pfam_db_version = f_annotate.pfam_db_version,
      hmmsearch_cath_funfam_version = f_annotate.hmmsearch_cath_funfam_version,
      cath_funfam_db_version = f_annotate.cath_funfam_db_version
  }

  call gff_and_fasta_stats.gff_and_fasta_stats as final_stats {
    input:
      imgap_project_id = imgap_project_id,
      final_gff = mo.structural_gff,
      imgap_input_fasta = mmf.out_fasta,
      container = container
  }

  call finish_ano.finish_ano as fin {
    input:
      container = container,
      proj = proj,
      ano_info_file = mif.imgap_info,
      proteins_faa = mo.proteins_faa,
      structural_gff = mo.structural_gff,
      ko_ec_gff = mo.ko_ec_gff,
      gene_phylogeny_tsv = mo.gene_phylogeny_tsv,
      functional_gff = mo.functional_gff,
      lineage_tsv = mo.lineage_tsv,
      ko_tsv = mo.ko_tsv,
      ec_tsv = mo.ec_tsv,
      stats_tsv = final_stats.tsv,
      stats_json = final_stats.json,
      cog_gff = mo.cog_gff,
      pfam_gff = mo.pfam_gff,
      tigrfam_gff = mo.tigrfam_gff,
      smart_gff = mo.smart_gff,
      supfam_gff = mo.supfam_gff,
      cath_funfam_gff = mo.cath_funfam_gff,
      crt_gff = mo.crt_gff,
      genemark_gff = mo.genemark_gff,
      prodigal_gff = mo.prodigal_gff,
      trna_gff = mo.trna_gff,
      rfam_gff = mo.rfam_gff,
      product_names_tsv = mo.product_names_tsv,
      crt_crisprs = mo.crt_crisprs,
      map_file = mmf.map_file,
      renamed_fasta = mmf.out_fasta,
      virus_summary = mo.virus_tsv,
      plasmid_summary = mo.plasmid_tsv,
      aggregated_class = mo.agg_class_tsv
  }

  output {
    File proteins_faa = fin.final_proteins_faa
    File structural_gff = fin.final_structural_gff
    File ko_ec_gff = fin.final_ko_ec_gff
    File gene_phylogeny_tsv = fin.final_gene_phylogeny_tsv
    File functional_gff = fin.final_functional_gff
    File ko_tsv = fin.final_ko_tsv
    File ec_tsv = fin.final_ec_tsv
    File lineage_tsv = fin.final_lineage_tsv
    File stats_tsv = fin.final_tsv
    File stats_json = fin.final_json
    File cog_gff = fin.final_cog_gff
    File pfam_gff = fin.final_pfam_gff
    File tigrfam_gff = fin.final_tigrfam_gff
    File smart_gff = fin.final_smart_gff
    File supfam_gff = fin.final_supfam_gff
    File cath_funfam_gff = fin.final_cath_funfam_gff
    File crt_gff = fin.final_crt_gff
    File genemark_gff = fin.final_genemark_gff
    File prodigal_gff = fin.final_prodigal_gff
    File trna_gff = fin.final_trna_gff
    File final_rfam_gff = fin.final_rfam_gff
    File product_names_tsv = fin.final_product_names_tsv
    File crt_crisprs = fin.final_crt_crisprs
    File imgap_version = fin.final_version
    File renamed_fasta = fin.final_renamed_fasta
    File map_file = fin.final_map_file
    File virus_summary = fin.final_virus_summary
    File plasmid_summary = fin.final_plasmid_summary
    File aggregated_class = fin.final_aggregated_class
  }

  parameter_meta {
    imgap_input_fasta: "assembled contig file in fasta format"
    additional_threads: "optional for number of threads: 16"
    database_location: "File path to database. This should be /refdata for container runs"
    imgap_project_id: "Project ID string.  This will be appended to the gene ids"
    imgap_project_type: "Project Type (isolate, metagenome) defaults to metagenome"
    container: "Default container to use"
  }
  meta {
    author: "Brian Foster"
    email: "bfoster@lbl.gov"
    version: "1.0.0"
  }
}
