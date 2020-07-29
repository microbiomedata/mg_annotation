import "trnascan.wdl" as trnascan
import "rfam.wdl" as rfam
import "crt.wdl" as crt
import "prodigal.wdl" as prodigal
import "genemark.wdl" as genemark

workflow s_annotate {

  File    imgap_input_fasta
  String  imgap_project_id
  Int     additional_threads

  call pre_qc {
    input:
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id
  }

  call trnascan.trnascan {
    input:
      imgap_input_fasta = imgap_input_fasta,
      imgap_project_id = imgap_project_id,
      additional_threads = additional_threads
  }

  call rfam.rfam {
    input:
      imgap_input_fasta = imgap_input_fasta,
      imgap_project_id = imgap_project_id,
      additional_threads = additional_threads
  }

  call crt.crt {
    input:
      imgap_input_fasta = imgap_input_fasta,
      imgap_project_id = imgap_project_id
  }

  call prodigal.prodigal {
    input:
      imgap_input_fasta = imgap_input_fasta,
      imgap_project_id = imgap_project_id
  }

  call genemark.genemark {
    input:
      imgap_input_fasta = imgap_input_fasta,
      imgap_project_id = imgap_project_id
  }

  call gff_merge {
    input:
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
      misc_and_regulatory_gff = rfam.misc_bind_misc_feature_regulatory_gff,
      rrna_gff = rfam.rrna_gff,
      trna_gff = trnascan.gff,
      ncrna_tmrna_gff = rfam.ncrna_tmrna_gff,
      crt_gff = crt.gff, 
      genemark_gff = genemark.gff,
      prodigal_gff = prodigal.gff
  }

  call fasta_merge {
    input:
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
      final_gff = gff_merge.final_gff,
      genemark_genes = genemark.genes,
      genemark_proteins = genemark.proteins,
      prodigal_genes = prodigal.genes,
      prodigal_proteins = prodigal.proteins
  }

  output {
    File  gff = gff_merge.final_gff
    File? proteins = fasta_merge.final_proteins 
  }
}

task pre_qc {

  String bin="/opt/omics/bin/qc/pre-annotation/fasta_sanity.py"
  File   input_fasta
  String project_id
  String rename = "yes"
  Float  n_ratio_cutoff = 0.5
  Int    seqs_per_million_bp_cutoff = 500
  Int    min_seq_length = 150

  command <<<
    tmp_fasta="${input_fasta}.tmp"
    qced_fasta="${project_id}_contigs.fna"
    grep -v '^\s*$' ${input_fasta} | tr -d '\r' | \
    sed 's/^>[[:blank:]]*/>/g' > $tmp_fasta
    acgt_count=`grep -v '^>' $tmp_fasta | grep -o [acgtACGT] | wc -l`
    n_count=`grep -v '^>' $tmp_fasta | grep -o '[^acgtACGT]' | wc -l`
    n_ratio=`echo $n_count $acgt_count | awk '{printf "%f", $1 / $2}'`
    if (( $(echo "$n_ratio >= ${n_ratio_cutoff}" | bc) ))
    then
        rm $tmp_fasta
        exit 1
    fi

    fasta_sanity_cmd="${bin} $tmp_fasta $qced_fasta"
    if [[ ${rename} == "yes" ]]
    then
        fasta_sanity_cmd="$fasta_sanity_cmd -p ${project_id}"
    fi
    fasta_sanity_cmd="$fasta_sanity_cmd -l ${min_seq_length}"
    $fasta_sanity_cmd
    rm $tmp_fasta
  >>>

  runtime {
    time: "1:00:00"
    mem: "86G"
  }

  output {
    File fasta = "${project_id}_contigs.fna"
  }
}

task gff_merge {

  String bin="/opt/omics/bin/structural_annotation/gff_files_merger.py"
  File   input_fasta
  String project_id
  File?  misc_and_regulatory_gff
  File?  rrna_gff
  File?  trna_gff
  File?  ncrna_tmrna_gff
  File?  crt_gff
  File?  genemark_gff
  File?  prodigal_gff

  command {
    ${bin} -f ${input_fasta} ${"-a " + misc_and_regulatory_gff + " " + rrna_gff} \
    ${trna_gff} ${ncrna_tmrna_gff} ${crt_gff} \
    ${genemark_gff} ${prodigal_gff} 1> ${project_id}_structural_annotation.gff
  }

  runtime {
    time: "1:00:00"
    mem: "86G"
  }

  output {
    File final_gff = "${project_id}_structural_annotation.gff"
  }
}

task fasta_merge {

  String bin = "/opt/omics/bin/structural_annotation/fasta_files_merger.py"
  File   input_fasta
  String project_id
  File   final_gff
  File?  genemark_genes
  File?  genemark_proteins
  File?  prodigal_genes
  File?  prodigal_proteins

  command {
    ${bin} ${final_gff} ${genemark_genes} ${prodigal_genes} 1> ${project_id}_genes.fna
    ${bin} ${final_gff} ${genemark_proteins} ${prodigal_proteins} 1> ${project_id}_proteins.faa
  }

  runtime {
    time: "1:00:00"
    mem: "86G"
  }

  output {
    File final_genes = "${project_id}_genes.fna"
    File final_proteins = "${project_id}_proteins.faa"
  }
}

task gff_and_fasta_stats {

  String bin="/opt/omics/bin/structural_annotation/gff_and_final_fasta_stats.py"
  File   input_fasta
  String project_id
  File   final_gff

  command {
    ${bin} ${input_fasta} ${final_gff} && sleep 2
    mv ../inputs/*/assembly_structural_annotation_stats.tsv .
  }

  output {
    File tsv = "assembly_structural_annotation_stats.tsv"
  }

  runtime {
    time: "1:00:00"
    mem: "86G"
  }
}

