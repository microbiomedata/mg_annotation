version 1.0
import "./structural-annotation.wdl" as sa
import "./functional-annotation.wdl" as fa

workflow annotation {
  input{
    File    imgap_input_fasta
    String  imgap_project_id="GaXXXXXXX_contigs.fna"
    String  database_location="/refdata/img/"
    String  imgap_project_type="metagenome"
    Int     additional_threads=16
    String  container="microbiomedata/img-omics@sha256:d5f4306bf36a97d55a3710280b940b89d7d4aca76a343e75b0e250734bc82b71"
    String bc_bin="/miniconda3/bin/bc"
    # structural annotation
    #Boolean sa_execute=true

    # functional annotation
    #Boolean fa_execute=true
    String? gm_license
    }
  call split {
    input: infile=imgap_input_fasta,
           container=container
  }

  scatter(pathname in split.files) {
      call sa.s_annotate {
        input:
          cmzscore = split.cmzscore,
          #imgap_input_fasta = imgap_input_fasta,
          imgap_input_fasta = pathname,
          imgap_project_id = imgap_project_id,
          additional_threads = additional_threads,
          imgap_project_type = imgap_project_type,
          database_location = database_location,
          rfam_execute = false,
          container=container,
          gm_license=gm_license
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
       proteins = s_annotate.proteins,
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
       container=container
  }
  call final_stats {
    input:
       project_id = imgap_project_id,
       structural_gff = merge_outputs.structural_gff,
       input_fasta = imgap_input_fasta,
       container=container
  }
  output {
    File? proteins_faa = merge_outputs.proteins_faa
    File? structural_gff = merge_outputs.structural_gff
    File? ko_ec_gff = merge_outputs.ko_ec_gff
    File? gene_phylogeny_tsv = merge_outputs.gene_phylogeny_tsv
    File? functional_gff = merge_outputs.functional_gff
    File? ko_tsv = merge_outputs.ko_tsv
    File? ec_tsv = merge_outputs.ec_tsv
    File? stats_tsv = final_stats.tsv
    File? stats_json = final_stats.json
    File? cog_gff = merge_outputs.cog_gff
    File? pfam_gff = merge_outputs.pfam_gff
    File? tigrfam_gff = merge_outputs.tigrfam_gff
    File? smart_gff = merge_outputs.smart_gff
    File? supfam_gff = merge_outputs.supfam_gff
    File? cath_funfam_gff = merge_outputs.cath_funfam_gff
    File? proteins_cog_domtblout = merge_outputs.proteins_cog_domtblout
    File? proteins_pfam_domtblout = merge_outputs.proteins_pfam_domtblout
    File? proteins_tigrfam_domtblout = merge_outputs.proteins_tigrfam_domtblout
    File? proteins_smart_domtblout = merge_outputs.proteins_smart_domtblout
    File? proteins_supfam_domtblout = merge_outputs.proteins_supfam_domtblout
    File? proteins_cath_funfam_domtblout = merge_outputs.proteins_cath_funfam_domtblout
    File? product_names_tsv = merge_outputs.product_names_tsv
    File? crt_crisprs = merge_outputs.crt_crisprs
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

task split{
   input{
     File infile
     String blocksize=10
     String zfile="zscore.txt"
     String cmzfile="cmzscore.txt"
     String container
     String? gm_license
   }
   command <<<
     set -euo pipefail
     /opt/omics/bin/split.py ~{infile} ~{blocksize} .
     echo $(egrep -v "^>" ~{infile} | tr -d '\n' | wc -m) / 500 | bc > ~{zfile}
     echo "scale=6; ($(grep -v '^>' ~{infile} | tr -d '\n' | wc -m) * 2) / 1000000" | bc -l > ~{cmzfile}
   >>>

   output{
     Array[File] files = read_lines('splits_out.fof')
     String zscore = read_string(zfile)
     String cmzscore = read_string(cmzfile)
   }
   runtime {
     memory: "120G"
     cpu:  16
     maxRetries: 1
     docker: container
   }
}


task merge_outputs {
  input{
    String  project_id
    String prefix=sub(project_id, ":", "_")
    Array[File?] structural_gffs
    Array[File?] functional_gffs
    Array[File?] ko_tsvs
    Array[File?] ec_tsvs
    Array[File?] phylo_tsvs
    Array[File?] proteins
    Array[File?] ko_ec_gffs
    Array[File?] cog_gffs
    Array[File?] pfam_gffs
    Array[File?] tigrfam_gffs
    Array[File?] smart_gffs
    Array[File?] supfam_gffs
    Array[File?] cath_funfam_gffs
    Array[File?] cog_domtblouts
    Array[File?] pfam_domtblouts
    Array[File?] tigrfam_domtblouts
    Array[File?] smart_domtblouts
    Array[File?] supfam_domtblouts
    Array[File?] cath_funfam_domtblouts
    Array[File?] product_name_tsvs
    Array[File?] crt_crisprs_s
    String container
    }
  command <<<
     set -eou pipefail
     cat ~{sep=" " structural_gffs} > "~{prefix}_structural_annotation.gff"
     cat ~{sep=" " functional_gffs} > "~{prefix}_functional_annotation.gff"
     cat ~{sep=" " ko_tsvs} >  "~{prefix}_ko.tsv"
     cat ~{sep=" " ec_tsvs} >  "~{prefix}_ec.tsv"
     cat ~{sep=" " phylo_tsvs} > "~{prefix}_gene_phylogeny.tsv"
     cat ~{sep=" " proteins} > "~{prefix}.faa"
     cat ~{sep=" " ko_ec_gffs} > "~{prefix}_ko_ec.gff"
     cat ~{sep=" " cog_gffs} > "~{prefix}_cog.gff"
     cat ~{sep=" " pfam_gffs} > "~{prefix}_pfam.gff"
     cat ~{sep=" " tigrfam_gffs} > "~{prefix}_tigrfam.gff"
     cat ~{sep=" " smart_gffs} > "~{prefix}_smart.gff"
     cat ~{sep=" " supfam_gffs} > "~{prefix}_supfam.gff"
     cat ~{sep=" " cath_funfam_gffs} > "~{prefix}_cath_funfam.gff"

     cat ~{sep=" " cog_domtblouts} > "~{prefix}_proteins.cog.domtblout"
     cat ~{sep=" " pfam_domtblouts} > "~{prefix}_proteins.pfam.domtblout"
     cat ~{sep=" " tigrfam_domtblouts} > "~{prefix}_proteins.tigrfam.domtblout"
     cat ~{sep=" " smart_domtblouts} > "~{prefix}_proteins.smart.domtblout"
     cat ~{sep=" " supfam_domtblouts} > "~{prefix}_proteins.supfam.domtblout"
     cat ~{sep=" " cath_funfam_domtblouts} > "~{prefix}_proteins.cath_funfam.domtblout"

     cat ~{sep=" " product_name_tsvs} > "~{prefix}_product_names.tsv"
     cat ~{sep=" " crt_crisprs_s} > "~{prefix}_crt.crisprs"
  >>>
  output {
    File functional_gff = "~{prefix}_functional_annotation.gff"
    File structural_gff = "~{prefix}_structural_annotation.gff"
    File ko_tsv = "~{prefix}_ko.tsv"
    File ec_tsv = "~{prefix}_ec.tsv"
    File gene_phylogeny_tsv = "~{prefix}_gene_phylogeny.tsv"
    File proteins_faa = "~{prefix}.faa"
    File ko_ec_gff = "~{prefix}_ko_ec.gff"
    File cog_gff = "~{prefix}_cog.gff"
    File pfam_gff = "~{prefix}_pfam.gff"
    File tigrfam_gff = "~{prefix}_tigrfam.gff"
    File smart_gff = "~{prefix}_smart.gff"
    File supfam_gff = "~{prefix}_supfam.gff"
    File cath_funfam_gff = "~{prefix}_cath_funfam.gff"

    File proteins_cog_domtblout = "~{prefix}_proteins.cog.domtblout"
    File proteins_pfam_domtblout = "~{prefix}_proteins.pfam.domtblout"
    File proteins_tigrfam_domtblout = "~{prefix}_proteins.tigrfam.domtblout"
    File proteins_smart_domtblout = "~{prefix}_proteins.smart.domtblout"
    File proteins_supfam_domtblout = "~{prefix}_proteins.supfam.domtblout"
    File proteins_cath_funfam_domtblout = "~{prefix}_proteins.cath_funfam.domtblout"
    File product_names_tsv = "~{prefix}_product_names.tsv"
    File crt_crisprs = "~{prefix}_crt.crisprs"
  }
  runtime {
    memory: "2G"
    cpu:  4
    maxRetries: 1
    docker: container
  }

# TODO:
#contig_names_mapping_tsv
#Coverage_file_cov

}

task final_stats {
  input{
    String bin="/opt/omics/bin/structural_annotation/gff_and_final_fasta_stats.py"
    File   input_fasta
    String project_id
    String prefix=sub(project_id, ":", "_")
    String fna="~{prefix}_contigs.fna"
    File   structural_gff
    String container
  }
  command <<<
    set -euo pipefail
    ln ~{input_fasta} ~{fna} || ln -s ~{input_fasta} ~{fna}
    ~{bin} ~{fna} ~{structural_gff}
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

