import "structural-annotation.wdl" as sa
import "functional-annotation.wdl" as fa

workflow annotation {
  String  proj
  String  resource
  String  informed_by
  String? git_url="https://github.com/microbiomedata/mg_annotation/releases/tag/0.1"
  String? url_root="https://data.microbiomedata.org/data/"
  String  input_file
  String  imgap_project_id
  String  database_location="/refdata/img/"
  String  imgap_project_type="metagenome"
  Int     additional_threads=16
  String  container="bfoster1/img-omics:0.1.9"

  # structural annotation
  Boolean sa_execute=true

  # functional annotation
  Boolean fa_execute=true

  call stage {
      input: container=container,
          input_file=input_file
    }

  call split {
    input: infile=stage.imgap_input_fasta,
           container=container
  }

  scatter(pathname in split.files) {
    if(sa_execute) {
      call sa.s_annotate {
        input:
          cmzscore = split.cmzscore,
          imgap_input_fasta = stage.imgap_input_fasta,
          imgap_input_fasta = pathname,
          imgap_project_id = imgap_project_id,
          additional_threads = additional_threads,
          imgap_project_type = imgap_project_type,
          database_location = database_location,
          container=container
      }
    }

    if(fa_execute) {
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
       crt_gffs = s_annotate.crt_gff,
       genemark_gffs = s_annotate.genemark_gff,
       prodigal_gffs = s_annotate.prodigal_gff,
       trna_gffs = s_annotate.trna_gff,
       misc_bind_misc_feature_regulatory_gffs = s_annotate.misc_bind_misc_feature_regulatory_gff,
       rrna_gffs = s_annotate.rrna_gff,
       ncrna_tmrna_gffs = s_annotate.ncrna_tmrna_gff,
       container=container
  }
  call final_stats {
    input:
       project_id = imgap_project_id,
       structural_gff = merge_outputs.structural_gff,
       input_fasta = stage.imgap_input_fasta,
       container=container
  }

  call finish_ano {
    input:
      container="microbiomedata/workflowmeta:1.1.1",
      input_file=stage.imgap_input_fasta,
      proj=proj,
      start=stage.start,
      resource=resource,
      url_root=url_root,
      git_url=git_url,
      informed_by=informed_by,
      proteins_faa = merge_outputs.proteins_faa,
      structural_gff = merge_outputs.structural_gff,
      ko_ec_gff = merge_outputs.ko_ec_gff,
      gene_phylogeny_tsv = merge_outputs.gene_phylogeny_tsv,
      functional_gff = merge_outputs.functional_gff,
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
      misc_bind_misc_feature_regulatory_gff = merge_outputs.misc_bind_misc_feature_regulatory_gff,
      rrna_gff = merge_outputs.rrna_gff,
      ncrna_tmrna_gff = merge_outputs.ncrna_tmrna_gff,
      product_names_tsv = merge_outputs.product_names_tsv,
      crt_crisprs = merge_outputs.crt_crisprs
  }

  output{
    File? proteins_faa = finish_ano.final_proteins_faa
    File? structural_gff = finish_ano.final_structural_gff
    File? ko_ec_gff = finish_ano.final_ko_ec_gff
    File? gene_phylogeny_tsv = finish_ano.final_gene_phylogeny_tsv
    File? functional_gff = finish_ano.final_functional_gff
    File? ko_tsv = finish_ano.final_ko_tsv
    File? ec_tsv = finish_ano.final_ec_tsv
    File? stats_tsv = finish_ano.final_tsv
    #File? stats_json = finish_ano.final_json
    File? cog_gff = finish_ano.final_cog_gff
    File? pfam_gff = finish_ano.final_pfam_gff
    File? tigrfam_gff = finish_ano.final_tigrfam_gff
    File? smart_gff = finish_ano.final_smart_gff
    File? supfam_gff = finish_ano.final_supfam_gff
    File? cath_funfam_gff = finish_ano.final_cath_funfam_gff
    File? crt_gff = finish_ano.final_crt_gff
    File? genemark_gff = finish_ano.final_genemark_gff
    File? prodigal_gff = finish_ano.final_prodigal_gff
    File? trna_gff = finish_ano.final_trna_gff
    File? misc_bind_misc_feature_regulatory_gff = finish_ano.final_misc_bind_misc_feature_regulatory_gff
    File? rrna_gff = finish_ano.final_rrna_gff
    File? ncrna_tmrna_gff = finish_ano.final_ncrna_tmrna_gff
    # File? proteins_cog_domtblout = finish_ano.final_proteins_cog_domtblout
    # File? proteins_pfam_domtblout = finish_ano.final_proteins_pfam_domtblout
    # File? proteins_tigrfam_domtblout = finish_ano.final_proteins_tigrfam_domtblout
    # File? proteins_smart_domtblout = finish_ano.final_proteins_smart_domtblout
    # File? proteins_supfam_domtblout = finish_ano.final_proteins_supfam_domtblout
    # File? proteins_cath_funfam_domtblout = finish_ano.final_proteins_cath_funfam_domtblout
    File? product_names_tsv = finish_ano.final_product_names_tsv
    File? crt_crisprs = finish_ano.final_crt_crisprs
    File? ano_objects = finish_ano.objects
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
   String container
   String target="input.fasta"
   String input_file

   command <<<
       set -e
       if [ $( echo ${input_file}|egrep -c "https*:") -gt 0 ] ; then
           wget ${input_file} -O ${target}
       else
           ln ${input_file} ${target} || cp ${input_file} ${target}
       fi
       # Capture the start time
       date --iso-8601=seconds > start.txt

   >>>

   output{
      File imgap_input_fasta = "${target}"
      String start = read_string("start.txt")
   }
   runtime {
     memory: "1 GiB"
     cpu:  2
     maxRetries: 1
     docker: container
   }
}

task split {
   File infile
   String blocksize=100
   String zfile="zscore.txt"
   String cmzfile="cmzscore.txt"
   String container

   command{
     set -euo pipefail
     /opt/omics/bin/split.py ${infile} ${blocksize} .
     echo $(egrep -v "^>" ${infile} | tr -d '\n' | wc -m) / 500 | bc > ${zfile}
     echo "scale=6; ($(grep -v '^>' ${infile} | tr -d '\n' | wc -m) * 2) / 1000000" | bc -l > ${cmzfile}
   }

   output{
     Array[File] files = read_lines('splits_out.fof')
     String zscore = read_string(zfile)
     String cmzscore = read_string(cmzfile)
   }
   runtime {
     memory: "120 GiB"
     cpu:  16
     maxRetries: 1
     docker: container
   }
}


task merge_outputs {
  String  project_id
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
  Array[File?] crt_gffs
  Array[File?] genemark_gffs
  Array[File?] prodigal_gffs
  Array[File?] trna_gffs
  Array[File?] misc_bind_misc_feature_regulatory_gffs
  Array[File?] rrna_gffs
  Array[File?] ncrna_tmrna_gffs
  String container

  command {
     cat ${sep=" " structural_gffs} > "${project_id}_structural_annotation.gff"
     cat ${sep=" " functional_gffs} > "${project_id}_functional_annotation.gff"
     cat ${sep=" " ko_tsvs} >  "${project_id}_ko.tsv"
     cat ${sep=" " ec_tsvs} >  "${project_id}_ec.tsv"
     cat ${sep=" " phylo_tsvs} > "${project_id}_gene_phylogeny.tsv"
     cat ${sep=" " proteins} > "${project_id}.faa"
     cat ${sep=" " ko_ec_gffs} > "${project_id}_ko_ec.gff"
     cat ${sep=" " cog_gffs} > "${project_id}_cog.gff"
     cat ${sep=" " pfam_gffs} > "${project_id}_pfam.gff"
     cat ${sep=" " tigrfam_gffs} > "${project_id}_tigrfam.gff"
     cat ${sep=" " smart_gffs} > "${project_id}_smart.gff"
     cat ${sep=" " supfam_gffs} > "${project_id}_supfam.gff"
     cat ${sep=" " cath_funfam_gffs} > "${project_id}_cath_funfam.gff"
     cat ${sep=" " crt_gffs} > "${project_id}_crt.gff"
     cat ${sep=" " genemark_gffs} > "${project_id}_genemark.gff"
     cat ${sep=" " prodigal_gffs} > "${project_id}_prodigal.gff"
     cat ${sep=" " trna_gffs} > "${project_id}_trna.gff"
     cat ${sep=" " misc_bind_misc_feature_regulatory_gffs} > "${project_id}_rfam_misc_bind_misc_feature_regulatory.gff"
     cat ${sep=" " rrna_gffs} > "${project_id}_rfam_rrna.gff"
     cat ${sep=" " ncrna_tmrna_gffs} > "${project_id}_rfam_ncrna_tmrna.gff"

     cat ${sep=" " cog_domtblouts} > "${project_id}_proteins.cog.domtblout"
     cat ${sep=" " pfam_domtblouts} > "${project_id}_proteins.pfam.domtblout"
     cat ${sep=" " tigrfam_domtblouts} > "${project_id}_proteins.tigrfam.domtblout"
     cat ${sep=" " smart_domtblouts} > "${project_id}_proteins.smart.domtblout"
     cat ${sep=" " supfam_domtblouts} > "${project_id}_proteins.supfam.domtblout"
     cat ${sep=" " cath_funfam_domtblouts} > "${project_id}_proteins.cath_funfam.domtblout"

     cat ${sep=" " product_name_tsvs} > "${project_id}_product_names.tsv"
     cat ${sep=" " crt_crisprs_s} > "${project_id}_crt.crisprs"
  }
  output {
    File functional_gff = "${project_id}_functional_annotation.gff"
    File structural_gff = "${project_id}_structural_annotation.gff"
    File ko_tsv = "${project_id}_ko.tsv"
    File ec_tsv = "${project_id}_ec.tsv"
    File gene_phylogeny_tsv = "${project_id}_gene_phylogeny.tsv"
    File proteins_faa = "${project_id}.faa"
    File ko_ec_gff = "${project_id}_ko_ec.gff"
    File cog_gff = "${project_id}_cog.gff"
    File pfam_gff = "${project_id}_pfam.gff"
    File tigrfam_gff = "${project_id}_tigrfam.gff"
    File smart_gff = "${project_id}_smart.gff"
    File supfam_gff = "${project_id}_supfam.gff"
    File cath_funfam_gff = "${project_id}_cath_funfam.gff"
    File crt_gff = "${project_id}_crt.gff"
    File genemark_gff = "${project_id}_genemark.gff"
    File prodigal_gff = "${project_id}_prodigal.gff"
    File trna_gff = "${project_id}_trna.gff"
    File misc_bind_misc_feature_regulatory_gff = "${project_id}_rfam_misc_bind_misc_feature_regulatory.gff"
    File rrna_gff = "${project_id}_rfam_rrna.gff"
    File ncrna_tmrna_gff = "${project_id}_rfam_ncrna_tmrna.gff"
    File proteins_cog_domtblout = "${project_id}_proteins.cog.domtblout"
    File proteins_pfam_domtblout = "${project_id}_proteins.pfam.domtblout"
    File proteins_tigrfam_domtblout = "${project_id}_proteins.tigrfam.domtblout"
    File proteins_smart_domtblout = "${project_id}_proteins.smart.domtblout"
    File proteins_supfam_domtblout = "${project_id}_proteins.supfam.domtblout"
    File proteins_cath_funfam_domtblout = "${project_id}_proteins.cath_funfam.domtblout"
    File product_names_tsv = "${project_id}_product_names.tsv"
    File crt_crisprs = "${project_id}_crt.crisprs"
  }
  runtime {
    memory: "2 GiB"
    cpu:  4
    maxRetries: 1
    docker: container
  }

}

task final_stats {
  String bin="/opt/omics/bin/structural_annotation/gff_and_final_fasta_stats.py"
  File   input_fasta
  String project_id
  String fna="${project_id}_contigs.fna"
  File   structural_gff
  String container

  command {
    set -euo pipefail
    ln ${input_fasta} ${fna}
    ${bin} ${fna} ${structural_gff}
  }

  output {
    File tsv = "${project_id}_structural_annotation_stats.tsv"
    File json = "${project_id}_structural_annotation_stats.json"
  }

  runtime {
    time: "0:10:00"
    memory: "86G"
    docker: container
  }
}

task finish_ano {
   String container
   File input_file
   String proj
   String prefix=sub(proj, ":", "_")
   String start
   String informed_by
   String resource
   String url_root
   String git_url
   File input_file
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
   File cath_funfam_gff
   File crt_gff
   File genemark_gff
   File prodigal_gff
   File trna_gff
   File misc_bind_misc_feature_regulatory_gff
   File rrna_gff
   File ncrna_tmrna_gff
   File ko_ec_gff
   File? stats_tsv
   File stats_json
   File product_names_tsv
   File crt_crisprs
   String orig_prefix="scaffold"
   String sed="s/${orig_prefix}_/${proj}_/g"

   command{

      set -e
      end=`date --iso-8601=seconds`
      #Generate annotation objects

       cat ${proteins_faa} | sed ${sed} > ${prefix}_proteins.faa
       cat ${structural_gff} | sed ${sed} > ${prefix}_structural_annotation.gff
       cat ${functional_gff} | sed ${sed} > ${prefix}_functional_annotation.gff
       cat ${ko_tsv} | sed ${sed} > ${prefix}_ko.tsv
       cat ${ec_tsv} | sed ${sed} > ${prefix}_ec.tsv
       cat ${cog_gff} | sed ${sed} > ${prefix}_cog.gff
       cat ${pfam_gff} | sed ${sed} > ${prefix}_pfam.gff
       cat ${tigrfam_gff} | sed ${sed} > ${prefix}_tigrfam.gff
       cat ${smart_gff} | sed ${sed} > ${prefix}_smart.gff
       cat ${supfam_gff} | sed ${sed} > ${prefix}_supfam.gff
       cat ${cath_funfam_gff} | sed ${sed} > ${prefix}_cath_funfam.gff
       cat ${crt_gff} | sed ${sed} > ${prefix}_crt.gff
       cat ${genemark_gff} | sed ${sed} > ${prefix}_genemark.gff
       cat ${prodigal_gff} | sed ${sed} > ${prefix}_prodigal.gff
       cat ${trna_gff} | sed ${sed} > ${prefix}_trna.gff
       cat ${misc_bind_misc_feature_regulatory_gff} | sed ${sed} > ${prefix}_rfam_misc_bind_misc_feature_regulatory.gff
       cat ${rrna_gff} | sed ${sed} > ${prefix}_rfam_rrna.gff
       cat ${ncrna_tmrna_gff} | sed ${sed} > ${prefix}_rfam_ncrna_tmrna.gff
       cat ${crt_crisprs} | sed ${sed} > ${prefix}_crt.crisprs
       cat ${gene_phylogeny_tsv} | sed ${sed} > ${prefix}_gene_phylogeny.tsv
       cat ${product_names_tsv} | sed ${sed} > ${prefix}_product_names.tsv
       cat ${ko_ec_gff} | sed ${sed} > ${prefix}_ko_ec.gff
       cat ${stats_tsv} | sed ${sed} > ${prefix}_stats.tsv
       cat ${stats_json} | sed ${sed} > ${prefix}_stats.json
       nmdc gff2json ${prefix}_functional_annotation.gff -of features.json -oa annotations.json -ai ${informed_by}

        /scripts/generate_object_json.py \
             --type "nmdc:MetagenomeAnnotationActivity" \
             --set metagenome_annotation_activity_set \
             --part ${proj} \
             -p "name=Annotation Activity for ${proj}" \
                was_informed_by=${informed_by} \
                started_at_time=${start} \
                ended_at_time=$end \
                execution_resource=${resource} \
                git_url=${git_url} \
                version="v1.0.0-beta" \
             --url ${url_root}${proj}/annotation/ \
             --inputs ${input_file} \
             --outputs \
             ${prefix}_proteins.faa "FASTA amino acid file for annotated proteins" "Annotation Amino Acid FASTA" "FASTA Amino Acid File for ${proj}" \
             ${prefix}_structural_annotation.gff "GFF3 format file with structural annotations" "Structural Annotation GFF" "Structural Annotation for ${proj}" \
             ${prefix}_functional_annotation.gff "GFF3 format file with functional annotations" "Functional Annotation GFF" "Functional Annotation for ${proj}" \
             ${prefix}_ko.tsv "Tab delimited file for KO annotation" "Annotation KEGG Orthology" "KEGG Orthology for ${proj}" \
             ${prefix}_ec.tsv "Tab delimited file for EC annotation" "Annotation Enzyme Commission" "EC Annotations for ${proj}" \
             ${prefix}_cog.gff "GFF3 format file with COGs" "Clusters of Orthologous Groups (COG) Annotation GFF" "COGs for ${proj}" \
             ${prefix}_pfam.gff "GFF3 format file with Pfam" "Pfam Annotation GFF" "Pfam Annotation for ${proj}" \
             ${prefix}_tigrfam.gff "GFF3 format file with TIGRfam" "TIGRFam Annotation GFF" "TIGRFam for ${proj}" \
             ${prefix}_smart.gff "GFF3 format file with SMART" "SMART Annotation GFF" "SMART Annotations for ${proj}" \
             ${prefix}_supfam.gff "GFF3 format file with SUPERFam" "SUPERFam Annotation GFF" "SUPERFam Annotations for ${proj}" \
             ${prefix}_cath_funfam.gff "GFF3 format file with CATH FunFams" "CATH FunFams (Functional Families) Annotation GFF" "CATH FunFams for ${proj}" \
             ${prefix}_crt.gff "GFF3 format file with CRT" "CRT Annotation GFF" "CRT Annotations for ${proj}" \
             ${prefix}_genemark.gff "GFF3 format file with Genemark" "Genemark Annotation GFF" "Genemark Annotations for ${proj}" \
             ${prefix}_prodigal.gff "GFF3 format file with Prodigal" "Prodigal Annotation GFF" " Prodigal Annotations ${proj}" \
             ${prefix}_trna.gff "GFF3 format file with TRNA" "TRNA Annotation GFF3" "TRNA Annotations ${proj}" \
             ${prefix}_rfam_misc_bind_misc_feature_regulatory.gff "GFF3 format file with Misc" "Misc Annotation GFF" "Misc Annotations for ${proj}" \
             ${prefix}_rfam_rrna.gff "GFF3 format file with RFAM" "RFAM Annotation GFF" "RFAM Annotations for ${proj}" \
             ${prefix}_rfam_ncrna_tmrna.gff "GFF3 format file with TMRNA" "TMRNA Annotation GFF3" "TMRNA Annotations for ${proj}"\
             ${prefix}_ko_ec.gff "GFF3 format file with KO_EC" "KO_EC Annotation GFF" "KO_EC Annotations for ${proj}" \
	           ${prefix}_product_names.tsv "Product names file" "Product names" "Product names for ${proj}"\
             ${prefix}_gene_phylogeny.tsv "Gene Phylogeny file" "Gene Phylogeny" "Gene Phylogeny for ${proj}"\
	           ${prefix}_crt.crisprs "Crisprt Terms" "Crisprt Terms" "Crispr Terms for ${proj}" \
             ${prefix}_stats.tsv "Annotation statistics report" "Annotation Statistics" "Annotation Stats for ${proj}"

   }

   output {
        File objects = "objects.json"
        File final_functional_gff = "${prefix}_functional_annotation.gff"
        File final_structural_gff = "${prefix}_structural_annotation.gff"
        File final_ko_tsv = "${prefix}_ko.tsv"
        File final_ec_tsv = "${prefix}_ec.tsv"
        File final_gene_phylogeny_tsv = "${prefix}_gene_phylogeny.tsv"
        File final_proteins_faa = "${prefix}_proteins.faa"
        File final_ko_ec_gff = "${prefix}_ko_ec.gff"
        File final_cog_gff = "${prefix}_cog.gff"
        File final_pfam_gff = "${prefix}_pfam.gff"
        File final_tigrfam_gff = "${prefix}_tigrfam.gff"
        File final_smart_gff = "${prefix}_smart.gff"
        File final_supfam_gff = "${prefix}_supfam.gff"
        File final_cath_funfam_gff = "${prefix}_cath_funfam.gff"
        File final_crt_gff = "${prefix}_crt.gff"
        File final_genemark_gff = "${prefix}_genemark.gff"
        File final_prodigal_gff = "${prefix}_prodigal.gff"
        File final_trna_gff = "${prefix}_trna.gff"
        File final_misc_bind_misc_feature_regulatory_gff = "${prefix}_rfam_misc_bind_misc_feature_regulatory.gff"
        File final_rrna_gff = "${prefix}_rfam_rrna.gff"
        File final_ncrna_tmrna_gff = "${prefix}_rfam_ncrna_tmrna.gff"
        # File final_proteins_cog_domtblout = "${prefix}_proteins.cog.domtblout"
        # File final_proteins_pfam_domtblout = "${prefix}_proteins.pfam.domtblout"
        # File final_proteins_tigrfam_domtblout = "${prefix}_proteins.tigrfam.domtblout"
        # File final_proteins_smart_domtblout = "${prefix}_proteins.smart.domtblout"
        # File final_proteins_supfam_domtblout = "${prefix}_proteins.supfam.domtblout"
        # File final_proteins_cath_funfam_domtblout = "${prefix}_proteins.cath_funfam.domtblout"
        File final_product_names_tsv = "${prefix}_product_names.tsv"
        File final_crt_crisprs = "${prefix}_crt.crisprs"
        File final_tsv = "${prefix}_stats.tsv"
        
    }
    runtime {
        memory: "10 GiB"
        cpu:  4
        maxRetries: 1
        docker: container
      }
  
}
