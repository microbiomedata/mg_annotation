version 1.0

workflow ko_ec {
    input {
        String imgap_project_id
        String imgap_project_type
        Int    additional_threads
        File   input_fasta
        String database_location="/refdata/img/"
        String ko_ec_img_nr_db="~{database_location}"+"/IMG-NR/20240916/img_nr"
        String ko_ec_md5_mapping="~{database_location}"+"/IMG-NR/20240916/md5Hash2Data.tsv"
        String ko_ec_taxon_to_phylo_mapping="~{database_location}"+"/IMG-NR/20240916/taxonOId2Taxonomy.tsv"
        String lastal_bin="/opt/omics/bin/lastal"
        String selector_bin="/opt/omics/bin/functional_annotation/lastal_img_nr_ko_ec_gene_phylo_hit_selector.py"
        String container
    }

  call run {
    input:
      project_id = imgap_project_id,
      project_type = imgap_project_type,
      input_fasta = input_fasta,
      threads = additional_threads,
      nr_db = ko_ec_img_nr_db,
      md5 = ko_ec_md5_mapping,
      phylo = ko_ec_taxon_to_phylo_mapping,
      lastal = lastal_bin,
      selector = selector_bin,
      container = container
  }

  output {
    File   last_blasttab = run.last_blasttab
    File   ko_tsv = run.ko_tsv
    File   ec_tsv = run.ec_tsv
    File   phylo_tsv = run.phylo_tsv
    File   gff = run.gff
    File   lineage_tsv = run.lineage_tsv
    String lastal_ver = run.lastal_ver
    String img_nr_db_ver = run.img_nr_db_ver
  }
}

task run {
    input {
        String project_id
        String prefix=sub(project_id, ":", "_")
        String project_type
        Int    threads = 2
        File   input_fasta
        String nr_db
        String md5
        String phylo
        Int    top_hits = 5
        Int    min_ko_hits = 2
        Float  aln_length_ratio = 0.7
        String lastal
        String selector
        String container
        String lastal_version_file = "lastal_version.txt"
        String img_nr_db_version_file = "img_db_version.txt"
    }
  command <<<
    set -euo pipefail
    ~{lastal} -m 180 -f blasttab+ -P ~{threads} ~{nr_db} ~{input_fasta} 1> ~{prefix}_proteins.img_nr.last.blasttab
    ~{selector} -l ~{aln_length_ratio} -m ~{min_ko_hits} -n ~{top_hits} \
                ~{project_type} ~{md5} ~{phylo} \
                ~{prefix}_ko.tsv ~{prefix}_ec.tsv \
                ~{prefix}_gene_phylogeny.tsv ~{prefix}_ko_ec.gff \
                ~{prefix}_proteins.img_nr.last.blasttab && \
    python /opt/omics/bin/functional_annotation/create_scaffold_lineage.py ~{prefix}_gene_phylogeny.tsv ~{prefix}_scaffold_lineage.tsv

    #get version information
    lastal_version="`~{lastal} -V`"
    echo $lastal_version > ~{lastal_version_file}
    img_nr_db_version="IMG-NR $(basename $(realpath $(dirname ~{nr_db})))"
    echo $img_nr_db_version > ~{img_nr_db_version_file}
  >>>

  runtime {
    time: "1:00:00"
    memory: "256G"
    docker: container
  }

  output {
    File   last_blasttab = "~{prefix}_proteins.img_nr.last.blasttab"
    File   ko_tsv = "~{prefix}_ko.tsv"
    File   ec_tsv = "~{prefix}_ec.tsv"
    File   phylo_tsv = "~{prefix}_gene_phylogeny.tsv"
    File   gff = "~{prefix}_ko_ec.gff"
    File   lineage_tsv = "~{prefix}_scaffold_lineage.tsv"
    String lastal_ver = read_string(lastal_version_file)
    String img_nr_db_ver = read_string(img_nr_db_version_file)
  }
}
