version 1.0

workflow merge_outputs {
    input {
        String      imgap_project_id
        Array[File] structural_gffs
        Array[File] functional_gffs
        Array[File] ko_tsvs
        Array[File] ec_tsvs
        Array[File] phylo_tsvs
        Array[File] last_blasttabs
        Array[File] lineage_tsvs
        Array[File] proteins
        Array[File] genes
        Array[File] ko_ec_gffs
        Array[File] cog_gffs
        Array[File] pfam_gffs
        Array[File] tigrfam_gffs
        Array[File] smart_gffs
        Array[File] supfam_gffs
        Array[File] cath_funfam_gffs
        Array[File] cog_domtblouts
        Array[File] pfam_domtblouts
        Array[File] tigrfam_domtblouts
        Array[File] smart_domtblouts
        Array[File] supfam_domtblouts
        Array[File] cath_funfam_domtblouts
        Array[File] product_name_tsvs
        Array[File] crt_crisprs_s
        Array[File] crt_gffs
        Array[File] crt_outs
        Array[File] genemark_gffs
        Array[File] genemark_genes
        Array[File] genemark_proteins
        Array[File] prodigal_gffs
        Array[File] prodigal_genes
        Array[File] prodigal_proteins
        Array[File] cds_gffs
        Array[File] cds_genes
        Array[File] cds_proteins
        Array[File] trna_gffs
        Array[File] trna_bacterial_outs
        Array[File] trna_archaeal_outs
        Array[File] rfam_gffs
        Array[File] rfam_tbls
        Array[File] virus_summary
        Array[File] plasmid_summary
        Array[File] aggregated_class
        String      container
    }

  call run {
    input:
      project_id = imgap_project_id,
      structural_gffs = structural_gffs,
      functional_gffs = functional_gffs,
      ko_tsvs = ko_tsvs,
      ec_tsvs = ec_tsvs,
      phylo_tsvs = phylo_tsvs,
      last_blasttabs = last_blasttabs,
      lineage_tsvs = lineage_tsvs,
      proteins = proteins,
      genes = genes,
      ko_ec_gffs = ko_ec_gffs,
      cog_gffs = cog_gffs,
      pfam_gffs = pfam_gffs,
      tigrfam_gffs = tigrfam_gffs,
      smart_gffs = smart_gffs,
      supfam_gffs = supfam_gffs,
      cath_funfam_gffs = cath_funfam_gffs,
      cog_domtblouts = cog_domtblouts,
      pfam_domtblouts = pfam_domtblouts,
      tigrfam_domtblouts = tigrfam_domtblouts,
      smart_domtblouts = smart_domtblouts,
      supfam_domtblouts = supfam_domtblouts,
      cath_funfam_domtblouts = cath_funfam_domtblouts,
      product_name_tsvs = product_name_tsvs,
      crt_crisprs_s = crt_crisprs_s,
      crt_gffs = crt_gffs,
      crt_outs = crt_outs,
      genemark_gffs = genemark_gffs,
      genemark_genes = genemark_genes,
      genemark_proteins = genemark_proteins,
      prodigal_gffs = prodigal_gffs,
      prodigal_genes = prodigal_genes,
      prodigal_proteins = prodigal_proteins,
      cds_gffs = cds_gffs,
      cds_genes = cds_genes,
      cds_proteins = cds_proteins,
      trna_gffs = trna_gffs,
      trna_bacterial_outs = trna_bacterial_outs,
      trna_archaeal_outs = trna_archaeal_outs,
      rfam_gffs = rfam_gffs,
      rfam_tbls = rfam_tbls,
      virus_summary = virus_summary,
      plasmid_summary = plasmid_summary,
      aggregated_class = aggregated_class,
      container = container
  }

  output {
    File functional_gff = run.functional_gff
    File structural_gff = run.structural_gff
    File ko_tsv = run.ko_tsv
    File ec_tsv = run.ec_tsv
    File gene_phylogeny_tsv = run.gene_phylogeny_tsv
    File last_blasttab = run.last_blasttab
    File lineage_tsv = run.lineage_tsv
    File proteins_faa = run.proteins_faa
    File genes_fna = run.genes_fna
    File ko_ec_gff = run.ko_ec_gff
    File cog_gff = run.cog_gff
    File pfam_gff = run.pfam_gff
    File tigrfam_gff = run.tigrfam_gff
    File smart_gff = run.smart_gff
    File supfam_gff = run.supfam_gff
    File cath_funfam_gff = run.cath_funfam_gff
    File crt_gff = run.crt_gff
    File genemark_gff = run.genemark_gff
    File genemark_gene = run.genemark_gene
    File genemark_protein = run.genemark_protein
    File prodigal_gff = run.prodigal_gff
    File prodigal_gene = run.prodigal_gene
    File prodigal_protein = run.prodigal_protein
    File cds_gff = run.cds_gff
    File cds_gene = run.cds_gene
    File cds_protein = run.cds_protein
    File trna_gff = run.trna_gff
    File trna_bacterial_out = run.trna_bacterial_out
    File trna_archaeal_out = run.trna_archaeal_out
    File rfam_gff = run.rfam_gff
    File rfam_tbl = run.rfam_tbl
    File proteins_cog_domtblout = run.proteins_cog_domtblout
    File proteins_pfam_domtblout = run.proteins_pfam_domtblout
    File proteins_tigrfam_domtblout = run.proteins_tigrfam_domtblout
    File proteins_smart_domtblout = run.proteins_smart_domtblout
    File proteins_supfam_domtblout = run.proteins_supfam_domtblout
    File proteins_cath_funfam_domtblout = run.proteins_cath_funfam_domtblout
    File product_names_tsv = run.product_names_tsv
    File crt_crisprs = run.crt_crisprs
    File crt_out = run.crt_out
    File virus_tsv = run.virus_tsv
    File plasmid_tsv = run.plasmid_tsv
    File agg_class_tsv = run.agg_class_tsv
  }
}

task run {
    input {
        String      project_id
        String      prefix=sub(project_id, ":", "_")
        Array[File] structural_gffs
        Array[File] functional_gffs
        Array[File] ko_tsvs
        Array[File] ec_tsvs
        Array[File] phylo_tsvs
        Array[File] last_blasttabs
        Array[File] lineage_tsvs
        Array[File] proteins
        Array[File] genes
        Array[File] ko_ec_gffs
        Array[File] cog_gffs
        Array[File] pfam_gffs
        Array[File] tigrfam_gffs
        Array[File] smart_gffs
        Array[File] supfam_gffs
        Array[File] cath_funfam_gffs
        Array[File] cog_domtblouts
        Array[File] pfam_domtblouts
        Array[File] tigrfam_domtblouts
        Array[File] smart_domtblouts
        Array[File] supfam_domtblouts
        Array[File] cath_funfam_domtblouts
        Array[File] product_name_tsvs
        Array[File] crt_crisprs_s
        Array[File] crt_gffs
        Array[File] crt_outs
        Array[File] genemark_gffs
        Array[File] genemark_genes
        Array[File] genemark_proteins
        Array[File] prodigal_gffs
        Array[File] prodigal_genes
        Array[File] prodigal_proteins
        Array[File] cds_gffs
        Array[File] cds_genes
        Array[File] cds_proteins
        Array[File] trna_gffs
        Array[File] trna_bacterial_outs
        Array[File] trna_archaeal_outs
        Array[File] rfam_gffs
        Array[File] rfam_tbls
        Array[File] virus_summary
        Array[File] plasmid_summary
        Array[File] aggregated_class
        String      container
    }

  command <<<
    set -eou pipefail
     #combine files
     cat ~{sep=" " structural_gffs} > "~{prefix}_structural_annotation.gff"
     cat ~{sep=" " functional_gffs} > "~{prefix}_functional_annotation.gff"
     cat ~{sep=" " ko_tsvs} > "~{prefix}_ko.tsv"
     cat ~{sep=" " ec_tsvs} > "~{prefix}_ec.tsv"
     cat ~{sep=" " phylo_tsvs} > "~{prefix}_gene_phylogeny.tsv"
     cat ~{sep=" " last_blasttabs} > "~{prefix}_proteins.img_nr.last.blasttab"
     cat ~{sep=" " lineage_tsvs} > "~{prefix}.contigLin.assembled.tsv"
     cat ~{sep=" " proteins} > "~{prefix}_proteins.faa"
     cat ~{sep=" " genes} > "~{prefix}_genes.fna"
     cat ~{sep=" " ko_ec_gffs} > "~{prefix}_ko_ec.gff"
     cat ~{sep=" " cog_gffs} > "~{prefix}_cog.gff"
     cat ~{sep=" " pfam_gffs} > "~{prefix}_pfam.gff"
     cat ~{sep=" " tigrfam_gffs} > "~{prefix}_tigrfam.gff"
     cat ~{sep=" " smart_gffs} > "~{prefix}_smart.gff"
     cat ~{sep=" " supfam_gffs} > "~{prefix}_supfam.gff"
     cat ~{sep=" " cath_funfam_gffs} > "~{prefix}_cath_funfam.gff"
     cat ~{sep=" " product_name_tsvs} > "~{prefix}_product_names.tsv"
     cat ~{sep=" " genemark_gffs} > "~{prefix}_genemark.gff"
     cat ~{sep=" " genemark_genes} > "~{prefix}_genemark_genes.fna"
     cat ~{sep=" " genemark_proteins} > "~{prefix}_genemark_proteins.faa"
     cat ~{sep=" " prodigal_gffs} > "~{prefix}_prodigal.gff"
     cat ~{sep=" " prodigal_proteins} > "~{prefix}_prodigal_proteins.faa"
     cat ~{sep=" " prodigal_genes} > "~{prefix}_prodigal_genes.fna"
     cat ~{sep=" " cds_gffs} > "~{prefix}_cds.gff"
     cat ~{sep=" " cds_proteins} > "~{prefix}_cds_proteins.faa"
     cat ~{sep=" " cds_genes} > "~{prefix}_cds_genes.fna"
     cat ~{sep=" " trna_gffs} > "~{prefix}_trna.gff"
     cat ~{sep=" " trna_bacterial_outs} > "~{prefix}_trnascan_bacterial.out"
     cat ~{sep=" " trna_archaeal_outs} > "~{prefix}_trnascan_archaeal.out"
     cat ~{sep=" " rfam_gffs} > "~{prefix}_rfam.gff"
     cat ~{sep=" " rfam_tbls} > "~{prefix}_rfam.tbl"
     cat ~{sep=" " cog_domtblouts} > "~{prefix}_proteins.cog.domtblout"
     cat ~{sep=" " pfam_domtblouts} > "~{prefix}_proteins.pfam.domtblout"
     cat ~{sep=" " tigrfam_domtblouts} > "~{prefix}_proteins.tigrfam.domtblout"
     cat ~{sep=" " smart_domtblouts} > "~{prefix}_proteins.smart.domtblout"
     cat ~{sep=" " supfam_domtblouts} > "~{prefix}_proteins.supfam.domtblout"
     cat ~{sep=" " cath_funfam_domtblouts} > "~{prefix}_proteins.cath_funfam.domtblout"
     cat ~{sep=" " crt_crisprs_s} > "~{prefix}_crt.crisprs"
     cat ~{sep=" " crt_gffs} > "~{prefix}_crt.gff"
     cat ~{sep=" " crt_outs} > "~{prefix}_crt.out"
     cat ~{sep=" " virus_summary} > "~{prefix}_genomad_virus_summary.tsv"
     cat ~{sep=" " plasmid_summary} > "~{prefix}_genomad_plasmid_summary.tsv"
     cat ~{sep=" " aggregated_class} > "~{prefix}_genomad_aggregated_classification.tsv"
  >>>

  output {
    File functional_gff = "~{prefix}_functional_annotation.gff"
    File structural_gff = "~{prefix}_structural_annotation.gff"
    File ko_tsv = "~{prefix}_ko.tsv"
    File ec_tsv = "~{prefix}_ec.tsv"
    File gene_phylogeny_tsv = "~{prefix}_gene_phylogeny.tsv"
    File last_blasttab = "~{prefix}_proteins.img_nr.last.blasttab"
    File lineage_tsv = "~{prefix}.contigLin.assembled.tsv"
    File proteins_faa = "~{prefix}_proteins.faa"
    File genes_fna = "~{prefix}_genes.fna"
    File ko_ec_gff = "~{prefix}_ko_ec.gff"
    File cog_gff = "~{prefix}_cog.gff"
    File pfam_gff = "~{prefix}_pfam.gff"
    File tigrfam_gff = "~{prefix}_tigrfam.gff"
    File smart_gff = "~{prefix}_smart.gff"
    File supfam_gff = "~{prefix}_supfam.gff"
    File cath_funfam_gff = "~{prefix}_cath_funfam.gff"
    File crt_gff = "~{prefix}_crt.gff"
    File genemark_gff = "~{prefix}_genemark.gff"
    File genemark_gene = "~{prefix}_genemark_genes.fna"
    File genemark_protein = "~{prefix}_genemark_proteins.faa"
    File prodigal_gff = "~{prefix}_prodigal.gff"
    File prodigal_gene = "~{prefix}_prodigal_genes.fna"
    File prodigal_protein = "~{prefix}_prodigal_proteins.faa"
    File cds_gff = "~{prefix}_cds.gff"
    File cds_gene = "~{prefix}_cds_genes.fna"
    File cds_protein = "~{prefix}_cds_proteins.faa"
    File trna_gff = "~{prefix}_trna.gff"
    File trna_bacterial_out = "~{prefix}_trnascan_bacterial.out"
    File trna_archaeal_out = "~{prefix}_trnascan_archaeal.out"
    File rfam_gff = "~{prefix}_rfam.gff"
    File rfam_tbl = "~{prefix}_rfam.tbl"
    File proteins_cog_domtblout = "~{prefix}_proteins.cog.domtblout"
    File proteins_pfam_domtblout = "~{prefix}_proteins.pfam.domtblout"
    File proteins_tigrfam_domtblout = "~{prefix}_proteins.tigrfam.domtblout"
    File proteins_smart_domtblout = "~{prefix}_proteins.smart.domtblout"
    File proteins_supfam_domtblout = "~{prefix}_proteins.supfam.domtblout"
    File proteins_cath_funfam_domtblout = "~{prefix}_proteins.cath_funfam.domtblout"
    File product_names_tsv = "~{prefix}_product_names.tsv"
    File crt_crisprs = "~{prefix}_crt.crisprs"
    File crt_out = "~{prefix}_crt.out"
    File virus_tsv = "~{prefix}_genomad_virus_summary.tsv"
    File plasmid_tsv = "~{prefix}_genomad_plasmid_summary.tsv"
    File agg_class_tsv = "~{prefix}_genomad_aggregated_classification.tsv"
  }

  runtime {
    memory: "2G"
    cpu: 4
    maxRetries: 1
    docker: container
  }
}
