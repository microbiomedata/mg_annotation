
## f_annotate

### Inputs

#### Required

  * `additional_threads` (Int, **required**)
  * `container` (String, **required**)
  * `database_location` (String, **required**)
  * `imgap_project_id` (String, **required**)
  * `imgap_project_type` (String, **required**)
  * `input_fasta` (File, **required**)
  * `sa_gff` (File, **required**)

#### Optional

  * `approx_num_proteins` (Int?)
  * `input_contigs_fasta` (File?)
  * `par_hmm_inst` (Int?)

#### Defaults

  * `cath_funfam_db` (String, default="~{database_location}" + "/Cath-FunFam/v4.2.0/funfam.hmm")
  * `cath_funfam_execute` (Boolean, default=true)
  * `cog_db` (String, default="~{database_location}" + "/COG/HMMs/2003/COG.hmm")
  * `cog_execute` (Boolean, default=true)
  * `frag_hits_filter_bin` (String, default="/opt/omics/bin/functional_annotation/hmmsearch_fragmented_hits_filter.py")
  * `hit_selector_bin` (String, default="/opt/omics/bin/functional_annotation/hmmsearch_hit_selector.py")
  * `hmm_container` (String, default="microbiomedata/img-omics@sha256:9f092d7616e0d996123e039d6c40e95663cb144a877b88ee7186df6559b02bc8")
  * `hmmsearch_bin` (String, default="/opt/omics/bin/hmmsearch")
  * `ko_ec_execute` (Boolean, default=true)
  * `ko_ec_img_nr_db` (String, default="~{database_location}" + "/IMG-NR/20211118/img_nr")
  * `ko_ec_md5_mapping` (String, default="~{database_location}" + "/IMG-NR/20211118/md5Hash2Data.txt")
  * `ko_ec_taxon_to_phylo_mapping` (String, default="~{database_location}" + "/IMG-NR/20211118/taxonOid2Taxonomy.txt")
  * `last_container` (String, default="microbiomedata/img-omics@sha256:9f092d7616e0d996123e039d6c40e95663cb144a877b88ee7186df6559b02bc8")
  * `lastal_bin` (String, default="/opt/omics/bin/lastal")
  * `pfam_clan_filter` (String, default="/opt/omics/bin/functional_annotation/pfam_clan_filter.py")
  * `pfam_claninfo_tsv` (String, default="~{database_location}" + "/Pfam/Pfam-A/v34.0/Pfam-A.clans.tsv")
  * `pfam_db` (String, default="~{database_location}" + "/Pfam/Pfam-A/v34.0/Pfam-A.v34.0.hmm")
  * `pfam_execute` (Boolean, default=true)
  * `product_assign_bin` (String, default="/opt/omics/bin/functional_annotation/assign_product_names_and_create_fa_gff.py")
  * `product_names_mapping_dir` (String, default="~{database_location}" + "/Product_Name_Mappings/latest")
  * `selector_bin` (String, default="/opt/omics/bin/functional_annotation/lastal_img_nr_ko_ec_gene_phylo_hit_selector.py")
  * `smart_db` (String, default="~{database_location}" + "/SMART/01_06_2016/SMART.hmm")
  * `smart_execute` (Boolean, default=true)
  * `superfam_db` (String, default="~{database_location}" + "/SuperFamily/v1.75/supfam.hmm")
  * `superfam_execute` (Boolean, default=true)
  * `tigrfam_db` (String, default="~{database_location}" + "/TIGRFAM/v15.0/TIGRFAM.hmm")
  * `tigrfam_execute` (Boolean, default=true)
  * `cath_funfam.aln_length_ratio` (Float, default=0.7)
  * `cath_funfam.base` (String, default=basename(input_fasta))
  * `cath_funfam.cath_funfam_db_version_file` (String, default="cath_funfam_db_version.txt")
  * `cath_funfam.hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `cath_funfam.max_overlap_ratio` (Float, default=0.1)
  * `cath_funfam.min_domain_eval_cutoff` (Float, default=0.01)
  * `cog.aln_length_ratio` (Float, default=0.7)
  * `cog.base` (String, default=basename(input_fasta))
  * `cog.cog_db_version_file` (String, default="cog_db_version.txt")
  * `cog.hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `cog.max_overlap_ratio` (Float, default=0.1)
  * `cog.min_domain_eval_cutoff` (Float, default=0.01)
  * `ko_ec.aln_length_ratio` (Float, default=0.7)
  * `ko_ec.img_nr_db_version_file` (String, default="img_db_version.txt")
  * `ko_ec.lastal_version_file` (String, default="lastal_version.txt")
  * `ko_ec.min_ko_hits` (Int, default=2)
  * `ko_ec.top_hits` (Int, default=5)
  * `pfam.base` (String, default=basename(input_fasta))
  * `pfam.hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `pfam.pfam_db_version_file` (String, default="pfam_db_version.txt")
  * `smart.aln_length_ratio` (Float, default=0.7)
  * `smart.base` (String, default=basename(input_fasta))
  * `smart.hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `smart.max_overlap_ratio` (Float, default=0.1)
  * `smart.min_domain_eval_cutoff` (Float, default=0.01)
  * `smart.smart_db_version_file` (String, default="smart_db_version.txt")
  * `superfam.aln_length_ratio` (Float, default=0.7)
  * `superfam.base` (String, default=basename(input_fasta))
  * `superfam.hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `superfam.max_overlap_ratio` (Float, default=0.1)
  * `superfam.min_domain_eval_cutoff` (Float, default=0.01)
  * `superfam.superfam_db_version_file` (String, default="superfam_db_version.txt")
  * `tigrfam.aln_length_ratio` (Float, default=0.7)
  * `tigrfam.base` (String, default=basename(input_fasta))
  * `tigrfam.hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `tigrfam.max_overlap_ratio` (Float, default=0.1)
  * `tigrfam.tigrfam_db_version_file` (String, default="tigrfam_db_version.txt")

### Outputs

  * `gff` (File?)
  * `product_name_tsv` (File?)
  * `ko_tsv` (File?)
  * `ec_tsv` (File?)
  * `phylo_tsv` (File?)
  * `ko_ec_gff` (File?)
  * `last_blasttab` (File?)
  * `cog_gff` (File?)
  * `pfam_gff` (File?)
  * `tigrfam_gff` (File?)
  * `supfam_gff` (File?)
  * `smart_gff` (File?)
  * `cath_funfam_gff` (File?)
  * `cog_domtblout` (File?)
  * `pfam_domtblout` (File?)
  * `tigrfam_domtblout` (File?)
  * `supfam_domtblout` (File?)
  * `smart_domtblout` (File?)
  * `cath_funfam_domtblout` (File?)
  * `lastal_version` (String?)
  * `img_nr_db_version` (String?)
  * `hmmsearch_smart_version` (String?)
  * `smart_db_version` (String?)
  * `hmmsearch_cog_version` (String?)
  * `cog_db_version` (String?)
  * `hmmsearch_tigrfam_version` (String?)
  * `tigrfam_db_version` (String?)
  * `hmmsearch_superfam_version` (String?)
  * `superfam_db_version` (String?)
  * `hmmsearch_pfam_version` (String?)
  * `pfam_db_version` (String?)
  * `hmmsearch_cath_funfam_version` (String?)
  * `cath_funfam_db_version` (String?)

## ko_ec

### Inputs

#### Required

  * `container` (String, **required**)
  * `input_fasta` (File, **required**)
  * `lastal` (String, **required**)
  * `md5` (String, **required**)
  * `nr_db` (String, **required**)
  * `phylo` (String, **required**)
  * `project_id` (String, **required**)
  * `project_type` (String, **required**)
  * `selector` (String, **required**)

#### Defaults

  * `aln_length_ratio` (Float, default=0.7)
  * `img_nr_db_version_file` (String, default="img_db_version.txt")
  * `lastal_version_file` (String, default="lastal_version.txt")
  * `min_ko_hits` (Int, default=2)
  * `threads` (Int, default=2)
  * `top_hits` (Int, default=5)

### Outputs

  * `last_blasttab` (File)
  * `ko_tsv` (File)
  * `ec_tsv` (File)
  * `phylo_tsv` (File)
  * `gff` (File)
  * `lastal_ver` (String)
  * `img_nr_db_ver` (String)

## smart

### Inputs

#### Required

  * `container` (String, **required**)
  * `frag_hits_filter` (String, **required**)
  * `hmmsearch` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)
  * `smart_db` (String, **required**)

#### Defaults

  * `aln_length_ratio` (Float, default=0.7)
  * `approx_num_proteins` (Int, default=0)
  * `base` (String, default=basename(input_fasta))
  * `hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `max_overlap_ratio` (Float, default=0.1)
  * `min_domain_eval_cutoff` (Float, default=0.01)
  * `par_hmm_inst` (Int, default=15)
  * `smart_db_version_file` (String, default="smart_db_version.txt")
  * `threads` (Int, default=62)

### Outputs

  * `gff` (File)
  * `domtblout` (File)
  * `hmmsearch_smart_ver` (String)
  * `smart_db_ver` (String)

## cog

### Inputs

#### Required

  * `cog_db` (String, **required**)
  * `container` (String, **required**)
  * `frag_hits_filter` (String, **required**)
  * `hmmsearch` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)

#### Defaults

  * `aln_length_ratio` (Float, default=0.7)
  * `approx_num_proteins` (Int, default=0)
  * `base` (String, default=basename(input_fasta))
  * `cog_db_version_file` (String, default="cog_db_version.txt")
  * `hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `max_overlap_ratio` (Float, default=0.1)
  * `min_domain_eval_cutoff` (Float, default=0.01)
  * `par_hmm_inst` (Int, default=15)
  * `threads` (Int, default=62)

### Outputs

  * `gff` (File)
  * `domtblout` (File)
  * `hmmsearch_cog_ver` (String)
  * `cog_db_ver` (String)

## tigrfam

### Inputs

#### Required

  * `container` (String, **required**)
  * `hit_selector` (String, **required**)
  * `hmmsearch` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)
  * `tigrfam_db` (String, **required**)

#### Defaults

  * `aln_length_ratio` (Float, default=0.7)
  * `approx_num_proteins` (Int, default=0)
  * `base` (String, default=basename(input_fasta))
  * `hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `max_overlap_ratio` (Float, default=0.1)
  * `par_hmm_inst` (Int, default=15)
  * `threads` (Int, default=62)
  * `tigrfam_db_version_file` (String, default="tigrfam_db_version.txt")

### Outputs

  * `gff` (File)
  * `domtblout` (File)
  * `hmmsearch_tigrfam_ver` (String)
  * `tigrfam_db_ver` (String)

## superfam

### Inputs

#### Required

  * `container` (String, **required**)
  * `frag_hits_filter` (String, **required**)
  * `hmmsearch` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)
  * `superfam_db` (String, **required**)

#### Defaults

  * `aln_length_ratio` (Float, default=0.7)
  * `approx_num_proteins` (Int, default=0)
  * `base` (String, default=basename(input_fasta))
  * `hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `max_overlap_ratio` (Float, default=0.1)
  * `min_domain_eval_cutoff` (Float, default=0.01)
  * `par_hmm_inst` (Int, default=15)
  * `superfam_db_version_file` (String, default="superfam_db_version.txt")
  * `threads` (Int, default=62)

### Outputs

  * `gff` (File)
  * `domtblout` (File)
  * `hmmsearch_superfam_ver` (String)
  * `superfam_db_ver` (String)

## pfam

### Inputs

#### Required

  * `container` (String, **required**)
  * `hmmsearch` (String, **required**)
  * `input_fasta` (File, **required**)
  * `pfam_clan_filter` (String, **required**)
  * `pfam_claninfo_tsv` (String, **required**)
  * `pfam_db` (String, **required**)
  * `project_id` (String, **required**)

#### Defaults

  * `approx_num_proteins` (Int, default=0)
  * `base` (String, default=basename(input_fasta))
  * `hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `par_hmm_inst` (Int, default=15)
  * `pfam_db_version_file` (String, default="pfam_db_version.txt")
  * `threads` (Int, default=62)

### Outputs

  * `gff` (File)
  * `domtblout` (File)
  * `hmmsearch_pfam_ver` (String)
  * `pfam_db_ver` (String)

## cath_funfam

### Inputs

#### Required

  * `cath_funfam_db` (String, **required**)
  * `container` (String, **required**)
  * `frag_hits_filter` (String, **required**)
  * `hmmsearch` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)

#### Defaults

  * `aln_length_ratio` (Float, default=0.7)
  * `approx_num_proteins` (Int, default=0)
  * `base` (String, default=basename(input_fasta))
  * `cath_funfam_db_version_file` (String, default="cath_funfam_db_version.txt")
  * `hmmsearch_version_file` (String, default="hmmsearch_version.txt")
  * `max_overlap_ratio` (Float, default=0.1)
  * `min_domain_eval_cutoff` (Float, default=0.01)
  * `par_hmm_inst` (Int, default=15)
  * `threads` (Int, default=62)

### Outputs

  * `gff` (File)
  * `domtblout` (File)
  * `hmmsearch_cath_funfam_ver` (String)
  * `cath_funfam_db_ver` (String)

## signalp

### Inputs

#### Required

  * `container` (String, **required**)
  * `gram_stain` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)
  * `signalp` (String, **required**)

### Outputs

  * `gff` (File)

## tmhmm

### Inputs

#### Required

  * `container` (String, **required**)
  * `decode` (String, **required**)
  * `decode_parser` (String, **required**)
  * `input_fasta` (File, **required**)
  * `model` (String, **required**)
  * `project_id` (String, **required**)

### Outputs

  * `gff` (File)

## product_name

### Inputs

#### Required

  * `container` (String, **required**)
  * `map_dir` (String, **required**)
  * `product_assign` (String, **required**)
  * `project_id` (String, **required**)
  * `sa_gff` (File, **required**)

#### Optional

  * `cath_funfam_gff` (File?)
  * `cog_gff` (File?)
  * `ko_ec_gff` (File?)
  * `pfam_gff` (File?)
  * `smart_gff` (File?)
  * `supfam_gff` (File?)
  * `tigrfam_gff` (File?)

### Outputs

  * `gff` (File)
  * `tsv` (File)
