version 1.0

workflow finish_ano {
    input {
        String container
        String proj
        File   ano_info_file
        File   proteins_faa
        File   structural_gff
        File   functional_gff
        File   ko_tsv
        File   ec_tsv
        File   cog_gff
        File   pfam_gff
        File   tigrfam_gff
        File   smart_gff
        File   supfam_gff
        File   gene_phylogeny_tsv
        File   lineage_tsv
        File   cath_funfam_gff
        File   crt_gff
        File   genemark_gff
        File   prodigal_gff
        File   trna_gff
        File   rfam_gff
        File   ko_ec_gff
        File   stats_tsv
        File   stats_json
        File   product_names_tsv
        File   crt_crisprs
        File   map_file
        File   renamed_fasta
        File   virus_summary
        File   plasmid_summary
        File   aggregated_class
        String orig_prefix="scaffold"
    }

  call run {
    input:
      container = container,
      proj = proj,
      ano_info_file = ano_info_file,
      proteins_faa = proteins_faa,
      structural_gff = structural_gff,
      functional_gff = functional_gff,
      ko_tsv = ko_tsv,
      ec_tsv = ec_tsv,
      cog_gff = cog_gff,
      pfam_gff = pfam_gff,
      tigrfam_gff = tigrfam_gff,
      smart_gff = smart_gff,
      supfam_gff = supfam_gff,
      gene_phylogeny_tsv = gene_phylogeny_tsv,
      lineage_tsv = lineage_tsv,
      cath_funfam_gff = cath_funfam_gff,
      crt_gff = crt_gff,
      genemark_gff = genemark_gff,
      prodigal_gff = prodigal_gff,
      trna_gff = trna_gff,
      rfam_gff = rfam_gff,
      ko_ec_gff = ko_ec_gff,
      stats_tsv = stats_tsv,
      stats_json = stats_json,
      product_names_tsv = product_names_tsv,
      crt_crisprs = crt_crisprs,
      map_file = map_file,
      renamed_fasta = renamed_fasta,
      virus_summary = virus_summary,
      plasmid_summary = plasmid_summary,
      aggregated_class = aggregated_class,
      orig_prefix = orig_prefix
  }

  output {
    File final_functional_gff = run.final_functional_gff
    File final_structural_gff = run.final_structural_gff
    File final_ko_tsv = run.final_ko_tsv
    File final_ec_tsv = run.final_ec_tsv
    File final_gene_phylogeny_tsv = run.final_gene_phylogeny_tsv
    File final_proteins_faa = run.final_proteins_faa
    File final_ko_ec_gff = run.final_ko_ec_gff
    File final_cog_gff = run.final_cog_gff
    File final_pfam_gff = run.final_pfam_gff
    File final_tigrfam_gff = run.final_tigrfam_gff
    File final_smart_gff = run.final_smart_gff
    File final_supfam_gff = run.final_supfam_gff
    File final_cath_funfam_gff = run.final_cath_funfam_gff
    File final_crt_gff = run.final_crt_gff
    File final_genemark_gff = run.final_genemark_gff
    File final_prodigal_gff = run.final_prodigal_gff
    File final_trna_gff = run.final_trna_gff
    File final_rfam_gff = run.final_rfam_gff
    File final_product_names_tsv = run.final_product_names_tsv
    File final_lineage_tsv = run.final_lineage_tsv
    File final_crt_crisprs = run.final_crt_crisprs
    File final_renamed_fasta = run.final_renamed_fasta
    File final_map_file = run.final_map_file
    File final_tsv = run.final_tsv
    File final_json = run.final_json
    File final_virus_summary = run.final_virus_summary
    File final_plasmid_summary = run.final_plasmid_summary
    File final_aggregated_class = run.final_aggregated_class
    File final_version = run.final_version
  }
}

task run {
    input {
        String container
        String proj
        String prefix=sub(proj, ":", "_")
        File   ano_info_file
        File   proteins_faa
        File   structural_gff
        File   functional_gff
        File   ko_tsv
        File   ec_tsv
        File   cog_gff
        File   pfam_gff
        File   tigrfam_gff
        File   smart_gff
        File   supfam_gff
        File   gene_phylogeny_tsv
        File   lineage_tsv
        File   cath_funfam_gff
        File   crt_gff
        File   genemark_gff
        File   prodigal_gff
        File   trna_gff
        File   rfam_gff
        File   ko_ec_gff
        File   stats_tsv
        File   stats_json
        File   product_names_tsv
        File   crt_crisprs
        File   map_file
        File   renamed_fasta
        File   virus_summary
        File   plasmid_summary
        File   aggregated_class
        String orig_prefix="scaffold"
        String sed="s/~{orig_prefix}_/~{proj}_/g"
    }

  command <<<
    set -eou pipefail
    end=`date --iso-8601=seconds`
    #Generate annotation objects

    cat ~{proteins_faa} | sed ~{sed} > ~{prefix}_proteins.faa
    cat ~{structural_gff} | sed ~{sed} > ~{prefix}_structural_annotation.gff
    cat ~{functional_gff} | sed ~{sed} > ~{prefix}_functional_annotation.gff
    cat ~{ko_tsv} | sed ~{sed} > ~{prefix}_ko.tsv
    cat ~{ec_tsv} | sed ~{sed} > ~{prefix}_ec.tsv
    cat ~{cog_gff} | sed ~{sed} > ~{prefix}_cog.gff
    cat ~{pfam_gff} | sed ~{sed} > ~{prefix}_pfam.gff
    cat ~{tigrfam_gff} | sed ~{sed} > ~{prefix}_tigrfam.gff
    cat ~{smart_gff} | sed ~{sed} > ~{prefix}_smart.gff
    cat ~{supfam_gff} | sed ~{sed} > ~{prefix}_supfam.gff
    cat ~{cath_funfam_gff} | sed ~{sed} > ~{prefix}_cath_funfam.gff
    cat ~{crt_gff} | sed ~{sed} > ~{prefix}_crt.gff
    cat ~{genemark_gff} | sed ~{sed} > ~{prefix}_genemark.gff
    cat ~{prodigal_gff} | sed ~{sed} > ~{prefix}_prodigal.gff
    cat ~{trna_gff} | sed ~{sed} > ~{prefix}_trna.gff
    cat ~{rfam_gff} | sed ~{sed} > ~{prefix}_rfam.gff
    cat ~{crt_crisprs} | sed ~{sed} > ~{prefix}_crt.crisprs
    cat ~{gene_phylogeny_tsv} | sed ~{sed} > ~{prefix}_gene_phylogeny.tsv
    cat ~{lineage_tsv} | sed ~{sed} > ~{prefix}_scaffold_lineage.tsv
    cat ~{product_names_tsv} | sed ~{sed} > ~{prefix}_product_names.tsv
    cat ~{ko_ec_gff} | sed ~{sed} > ~{prefix}_ko_ec.gff
    cat ~{stats_tsv} | sed ~{sed} > ~{prefix}_stats.tsv
    cat ~{stats_json} | sed ~{sed} > ~{prefix}_stats.json

    ln ~{ano_info_file} ~{prefix}_imgap.info || ln -s ~{ano_info_file} ~{prefix}_imgap.info
    ln ~{map_file} ~{prefix}_contig_names_mapping.tsv || ln -s ~{map_file} ~{prefix}_contig_names_mapping.tsv
    ln ~{renamed_fasta} ~{prefix}_contigs.fna || ln -s ~{renamed_fasta} ~{prefix}_contigs.fna

    ln ~{virus_summary} ~{prefix}_genomad_virus_summary.tsv || ln -s ~{virus_summary} ~{prefix}_genomad_virus_summary.tsv
    ln ~{plasmid_summary} ~{prefix}_genomad_plasmid_summary.tsv || ln -s ~{plasmid_summary} ~{prefix}_genomad_plasmid_summary.tsv
    ln ~{aggregated_class} ~{prefix}_genomad_aggregated_classification.tsv || ln -s ~{aggregated_class} ~{prefix}_genomad_aggregated_classification.tsv
  >>>

  output {
    File final_functional_gff = "~{prefix}_functional_annotation.gff"
    File final_structural_gff = "~{prefix}_structural_annotation.gff"
    File final_ko_tsv = "~{prefix}_ko.tsv"
    File final_ec_tsv = "~{prefix}_ec.tsv"
    File final_gene_phylogeny_tsv = "~{prefix}_gene_phylogeny.tsv"
    File final_proteins_faa = "~{prefix}_proteins.faa"
    File final_ko_ec_gff = "~{prefix}_ko_ec.gff"
    File final_cog_gff = "~{prefix}_cog.gff"
    File final_pfam_gff = "~{prefix}_pfam.gff"
    File final_tigrfam_gff = "~{prefix}_tigrfam.gff"
    File final_smart_gff = "~{prefix}_smart.gff"
    File final_supfam_gff = "~{prefix}_supfam.gff"
    File final_cath_funfam_gff = "~{prefix}_cath_funfam.gff"
    File final_crt_gff = "~{prefix}_crt.gff"
    File final_genemark_gff = "~{prefix}_genemark.gff"
    File final_prodigal_gff = "~{prefix}_prodigal.gff"
    File final_trna_gff = "~{prefix}_trna.gff"
    File final_rfam_gff = "~{prefix}_rfam.gff"
    File final_product_names_tsv = "~{prefix}_product_names.tsv"
    File final_lineage_tsv = "~{prefix}_scaffold_lineage.tsv"
    File final_crt_crisprs = "~{prefix}_crt.crisprs"
    File final_renamed_fasta = "~{prefix}_contigs.fna"
    File final_map_file = "~{prefix}_contig_names_mapping.tsv"
    File final_tsv = "~{prefix}_stats.tsv"
    File final_json = "~{prefix}_stats.json"
    File final_virus_summary = "~{prefix}_genomad_virus_summary.tsv"
    File final_plasmid_summary = "~{prefix}_genomad_plasmid_summary.tsv"
    File final_aggregated_class = "~{prefix}_genomad_aggregated_classification.tsv"
    File final_version = "~{prefix}_imgap.info"
  }

  runtime {
    memory: "10G"
    cpu: 4
    maxRetries: 1
    docker: container
  }
}
