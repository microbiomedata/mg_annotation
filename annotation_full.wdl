version 1.0

import "./structural-annotation.wdl" as sa
import "./functional-annotation.wdl" as fa

workflow annotation {
input {
  String  proj
  File    input_file
  String  imgap_project_id
  String  database_location="/refdata/img/"
  String  imgap_project_type="metagenome"
  File    gm_license="/refdata/licenses/.gmhmmp2_key"
  Int     additional_threads=16
  Int     additional_memory = 100
  String  container="microbiomedata/img-omics@sha256:d5f4306bf36a97d55a3710280b940b89d7d4aca76a343e75b0e250734bc82b71"

  # structural annotation
  Boolean sa_execute=true

  # functional annotation
  Boolean fa_execute=true
        }


 call stage {
      input: container=container,
          input_file=input_file
    }

  call make_map_file {
       input: proj_id = proj,
              input_file = stage.imgap_input_fasta,
              container = container
  }

  call split {
    input: infile=make_map_file.out_fasta,
           container=container
  }
  #confused for assembly or annotation id replacement
  scatter(pathname in split.files) {

      call sa.s_annotate {
        input:
          cmzscore = split.cmzscore,
          imgap_input_fasta = pathname,
          imgap_project_id = imgap_project_id,
          additional_threads = additional_threads,
          imgap_project_type = imgap_project_type,
          database_location = database_location,
          container=container,
          gm_license=gm_license,
          additional_memory = additional_memory
      }



      call fa.f_annotate {
        input:
          approx_num_proteins = split.zscore,
          imgap_project_id = imgap_project_id,
          imgap_project_type = imgap_project_type,
          additional_threads = additional_threads,
          input_fasta = s_annotate.proteins,
          database_location = database_location,
          sa_gff = s_annotate.gff,
          container=container
      }

  }
  call merge_outputs {
    input:
       project_id = imgap_project_id,
       product_name_tsvs = f_annotate.product_name_tsv,
       structural_gffs=s_annotate.gff,
       functional_gffs=f_annotate.gff,
       ko_tsvs = f_annotate.ko_tsv,
       ec_tsvs = f_annotate.ec_tsv,
       phylo_tsvs =  f_annotate.phylo_tsv,
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
       container=container
  }
  call make_info_file {
    input: project_id = imgap_project_id,
       container=container,
       sa_execute = sa_execute,
       fa_execute = fa_execute,
       map_info = make_map_file.out_log,
       structural_gff  = merge_outputs.structural_gff,
       imgap_version = split.imgap_version,
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

  call final_stats {
    input:
       project_id = imgap_project_id,
       structural_gff = merge_outputs.structural_gff,
       input_fasta = make_map_file.out_fasta,
       container=container
  }
# confused what to use for orig prefix
  call finish_ano {
    input:
      container=container,
      proj=proj,
      ano_info_file=make_info_file.imgap_info,
      proteins_faa = merge_outputs.proteins_faa,
      structural_gff = merge_outputs.structural_gff,
      ko_ec_gff = merge_outputs.ko_ec_gff,
      gene_phylogeny_tsv = merge_outputs.gene_phylogeny_tsv,
      functional_gff = merge_outputs.functional_gff,
      lineage_tsv = merge_outputs.lineage_tsv,
      ko_tsv = merge_outputs.ko_tsv,
      ec_tsv = merge_outputs.ec_tsv,
      stats_tsv = final_stats.tsv,
      stats_json = final_stats.json,
      cog_gff = merge_outputs.cog_gff,
      pfam_gff = merge_outputs.pfam_gff,
      tigrfam_gff = merge_outputs.tigrfam_gff,
      smart_gff = merge_outputs.smart_gff,
      supfam_gff = merge_outputs.supfam_gff,
      cath_funfam_gff = merge_outputs.cath_funfam_gff,
      crt_gff = merge_outputs.crt_gff,
      genemark_gff = merge_outputs.genemark_gff,
      prodigal_gff = merge_outputs.prodigal_gff,
      trna_gff = merge_outputs.trna_gff,
      rfam_gff = merge_outputs.rfam_gff,
      product_names_tsv = merge_outputs.product_names_tsv,
      crt_crisprs = merge_outputs.crt_crisprs,
      map_file = make_map_file.map_file,
      renamed_fasta = make_map_file.out_fasta
  }

  output{
    File proteins_faa = finish_ano.final_proteins_faa
    File structural_gff = finish_ano.final_structural_gff
    File ko_ec_gff = finish_ano.final_ko_ec_gff
    File gene_phylogeny_tsv = finish_ano.final_gene_phylogeny_tsv
    File functional_gff = finish_ano.final_functional_gff
    File ko_tsv = finish_ano.final_ko_tsv
    File ec_tsv = finish_ano.final_ec_tsv
    File lineage_tsv = finish_ano.final_lineage_tsv
    File stats_tsv = finish_ano.final_tsv
    File stats_json = finish_ano.final_json
    File cog_gff = finish_ano.final_cog_gff
    File pfam_gff = finish_ano.final_pfam_gff
    File tigrfam_gff = finish_ano.final_tigrfam_gff
    File smart_gff = finish_ano.final_smart_gff
    File supfam_gff = finish_ano.final_supfam_gff
    File cath_funfam_gff = finish_ano.final_cath_funfam_gff
    File crt_gff = finish_ano.final_crt_gff
    File genemark_gff = finish_ano.final_genemark_gff
    File prodigal_gff = finish_ano.final_prodigal_gff
    File trna_gff = finish_ano.final_trna_gff
    File final_rfam_gff = finish_ano.final_rfam_gff
 #   File proteins_cog_domtblout = finish_ano.final_proteins_cog_domtblout
 #   File proteins_pfam_domtblout = finish_ano.final_proteins_pfam_domtblout
 #   File proteins_tigrfam_domtblout = finish_ano.final_proteins_tigrfam_domtblout
 #   File proteins_smart_domtblout = finish_ano.final_proteins_smart_domtblout
 #   File proteins_supfam_domtblout = finish_ano.final_proteins_supfam_domtblout
 #   File proteins_cath_funfam_domtblout = finish_ano.final_proteins_cath_funfam_domtblout
    File product_names_tsv = finish_ano.final_product_names_tsv
    File crt_crisprs = finish_ano.final_crt_crisprs
    File imgap_version = finish_ano.final_version
    File renamed_fasta = finish_ano.final_renamed_fasta
    File map_file = finish_ano.final_map_file
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


task stage {
    input {
        String container
        String target="input.fasta"
        File   input_file
    }

   command <<<
       set -eou pipefail
       if [ $( echo ~{input_file}|egrep -c "https*:") -gt 0 ] ; then
           wget ~{input_file} -O ~{target}
       else
           ln ~{input_file} ~{target} || ln -s ~{input_file} ~{target}
       fi
       # Capture the start time
       date --iso-8601=seconds > start.txt

   >>>

   output{
      File imgap_input_fasta = "~{target}"
      String start = read_string("start.txt")
   }
   runtime {
     memory: "1G"
     cpu:  2
     maxRetries: 1
     docker: container
   }
}

task make_map_file {
  input{
    String proj_id
    String prefix=sub(proj_id, ":", "_")
    File   input_file
    String container
    Int min_seq_length = 150      # default value
    Int unknown_gap_length = 100  # default value
  }

  command <<<
    set -euo pipefail
 
    fasta_sanity.py -v
    fasta_sanity.py \
    -p ~{proj_id} \
    -l ~{min_seq_length} \
    -u ~{unknown_gap_length} \
    ~{input_file} ~{prefix}_map.fasta

  >>>

  output{
    File  map_file = "~{prefix}_contig_names_mapping.tsv"
    File  out_fasta = "~{prefix}_map.fasta"
    File  out_log = stdout()
 }
  runtime {
    memory: "120G"
     cpu:  16
     maxRetries: 1
     docker: container
  }
}

task split {
    input {
       File infile
       Int blocksize=100
       String zfile="zscore.txt"
       String cmzfile="cmzscore.txt"
       String container
       String imgap_version_file="imgap_version.txt"
   }

   command <<<
     set -euo pipefail
     /opt/omics/bin/split.py ~{infile} ~{blocksize} .
     echo $(egrep -v "^>" ~{infile} | tr -d '\n' | wc -m) / 500 | bc > ~{zfile}
     echo "scale=6; ($(grep -v '^>' ~{infile} | tr -d '\n' | wc -m) * 2) / 1000000" | bc -l > ~{cmzfile}
     cat /opt/omics/VERSION > ~{imgap_version_file}
   >>>

   output{
     Array[File] files = read_lines('splits_out.fof')
     String zscore = read_string(zfile)
     String cmzscore = read_string(cmzfile)
     String imgap_version = read_string(imgap_version_file)
   }

   runtime {
     memory: "120G"
     cpu:  16
     maxRetries: 1
     docker: container
   }
}


task merge_outputs {
    input {
      String  project_id
      String prefix=sub(project_id, ":", "_")
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
      String container
  }
 

  command <<<
    set -eou pipefail
     #combine files
     cat ~{sep=" " structural_gffs} > "~{prefix}_structural_annotation.gff"
     cat ~{sep=" " functional_gffs} > "~{prefix}_functional_annotation.gff"
     cat ~{sep=" " ko_tsvs} >  "~{prefix}_ko.tsv"
     cat ~{sep=" " ec_tsvs} >  "~{prefix}_ec.tsv"
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
  }
  runtime {
    memory: "2G"
    cpu:  4
    maxRetries: 1
    docker: container
  }

}

task make_info_file {
    input {
        String container
        String imgap_version
        File map_info
        Boolean fa_execute
        Boolean sa_execute
        String project_id
        String prefix=sub(project_id, ":", "_")
        Array[String] rfam_version
        Boolean rfam_executed = if (defined(rfam_version)) then true else false
        File structural_gff
        Array[String] lastal_version
        Array[String] img_nr_db_version
        Array[String] hmmsearch_smart_version
        Array[String] smart_db_version
        Array[String] hmmsearch_cog_version
        Array[String] cog_db_version
        Array[String] hmmsearch_tigrfam_version
        Array[String] tigrfam_db_version
        Array[String] hmmsearch_superfam_version
        Array[String] superfam_db_version
        Array[String] hmmsearch_pfam_version
        Array[String] pfam_db_version
        Array[String] hmmsearch_cath_funfam_version
        Array[String] cath_funfam_db_version
        String fa_version_file = "fa_tool_version.txt"
        String fa_db_version_file = "fa_db_version.txt"
        String rfam_version_file = "rfam_version.txt"
    }
  command <<<
    set -euo pipefail
     echo "IMGAP Version: ~{imgap_version}" > ~{prefix}_imgap.info
     #get map script version

     map_version=`grep "fasta_sanity.py" ~{map_info}`
     map_version="Mapping Programs Used: $map_version"
     echo $map_version >> ~{prefix}_imgap.info

     #get structual annotation versions
     if [[ "~{sa_execute}" = true ]]
       then
       sa_version=`cut -f2 ~{structural_gff}  | sort | uniq | perl -pe 's/\n/; /g' | sed -E 's/(.*)\; /\1/'`
       sa_version="Structural Annotation Programs Used: $sa_version"
       echo $sa_version >> ~{prefix}_imgap.info
       if [[ "~{rfam_executed}" = true ]]
         then
         echo ~{sep="," rfam_version} > ~{rfam_version_file}
         cat  ~{rfam_version_file} | tr ',' '\n' | sort | uniq  > rfam_version_uniq.txt

         rfam_db_version="Structural Annotation DBs Used:"
   #use while instead of for to handle the spaces in values
         while read db_version ; do
           rfam_db_version="$rfam_db_version $db_version; "
         done < rfam_version_uniq.txt
         rfam_db_version=`echo $rfam_db_version | sed -E 's/(.*)\;/\1/'`
         echo  $rfam_db_version  >> ~{prefix}_imgap.info
       fi
    fi
     #get functional annotation tool versions
     if [[ "~{fa_execute}" = true ]]
       then
       echo ~{sep="," lastal_version} > ~{fa_version_file}
       echo ~{sep="," hmmsearch_smart_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_cog_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_cog_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_tigrfam_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_superfam_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_pfam_version} >> ~{fa_version_file}
       echo ~{sep="," hmmsearch_cath_funfam_version} >> ~{fa_version_file}
       cat ~{fa_version_file} | tr ',' '\n' | sort | uniq  > fa_version_uniq.txt
       fa_tool_version="Functional Annotation Programs Used: "
       while read tool ; do
         fa_tool_version="$fa_tool_version $tool; "
       done < fa_version_uniq.txt
       fa_tool_version=`echo $fa_tool_version | sed -E 's/(.*)\;/\1/'`
       echo $fa_tool_version >> ~{prefix}_imgap.info
       #get functional annotation db versions
       echo ~{sep="," img_nr_db_version} > ~{fa_db_version_file}
       echo ~{sep="," smart_db_version} >> ~{fa_db_version_file}
       echo ~{sep="," cog_db_version} >> ~{fa_db_version_file}
       echo ~{sep="," tigrfam_db_version} >> ~{fa_db_version_file}
       echo ~{sep="," superfam_db_version} >> ~{fa_db_version_file}
       echo ~{sep="," pfam_db_version} >> ~{fa_db_version_file}
       echo ~{sep=","cath_funfam_db_version} >> ~{fa_db_version_file}
       cat ~{fa_db_version_file} | tr ',' '\n' | sort | uniq  > fa_db_version_uniq.txt
       fa_db_version="Functional Annotation DBs Used: "
       while read db ; do
         fa_db_version="$fa_db_version $db; "
       done < fa_db_version_uniq.txt
       fa_db_version=`echo $fa_db_version | sed -E 's/(.*)\;/\1/'`
       echo $fa_db_version >> ~{prefix}_imgap.info
    fi
  >>>

  output {
    File imgap_info = "~{prefix}_imgap.info"
  }
  runtime {
    memory: "2G"
    cpu:  4
    maxRetries: 1
    docker: container
  }

}


task final_stats {
    input {
        String bin="/opt/omics/bin/structural_annotation/gff_and_final_fasta_stats.py"
        File   input_fasta
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   structural_gff
        String container
    }

  command <<<
    set -euo pipefail
    ln ~{input_fasta} ~{prefix}_contigs.fna || ln -s ~{input_fasta} ~{prefix}_contigs.fna
    ~{bin} ~{prefix}_contigs.fna ~{structural_gff}
  >>>

  output {
    File tsv = "~{prefix}_structural_annotation_stats.tsv"
    File json = "~{prefix}_structural_annotation_stats.json"
  }

  runtime {
    time: "0:10:00"
    memory: "86G"
    docker: container
  }
}

task finish_ano {
    input {
       String container
       String proj
       String prefix=sub(proj, ":", "_")
       File ano_info_file
       File proteins_faa
       File structural_gff
       File functional_gff
       File ko_tsv
       File ec_tsv
       File cog_gff
       File pfam_gff
       File tigrfam_gff
       File smart_gff
       File supfam_gff
       File gene_phylogeny_tsv
       File lineage_tsv
       File cath_funfam_gff
       File crt_gff
       File genemark_gff
       File prodigal_gff
       File trna_gff
       File rfam_gff
       File ko_ec_gff
       File stats_tsv
       File stats_json
       File product_names_tsv
       File crt_crisprs
       File map_file
       File renamed_fasta
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
#        File final_proteins_cog_domtblout = "~{prefix}_proteins.cog.domtblout"
#        File final_proteins_pfam_domtblout = "~{prefix}_proteins.pfam.domtblout"
#        File final_proteins_tigrfam_domtblout = "~{prefix}_proteins.tigrfam.domtblout"
#        File final_proteins_smart_domtblout = "~{prefix}_proteins.smart.domtblout"
#        File final_proteins_supfam_domtblout = "~{prefix}_proteins.supfam.domtblout"
#        File final_proteins_cath_funfam_domtblout = "~{prefix}_proteins.cath_funfam.domtblout"
        File final_product_names_tsv = "~{prefix}_product_names.tsv"
        File final_lineage_tsv = "~{prefix}_scaffold_lineage.tsv"
        File final_crt_crisprs = "~{prefix}_crt.crisprs"
        File final_renamed_fasta = "~{prefix}_contigs.fna"
        File final_map_file = "~{prefix}_contig_names_mapping.tsv"
        File final_tsv = "~{prefix}_stats.tsv"
        File final_json = "~{prefix}_stats.json"
        File final_version = "~{prefix}_imgap.info"
 
    }
    runtime {
        memory: "10G"
        cpu:  4
        maxRetries: 1
        docker: container
      }

}
