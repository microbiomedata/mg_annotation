version 1.0

workflow cath_funfam {
    input {
        String imgap_project_id
        File   input_fasta
        Int    additional_threads
        Int?   par_hmm_inst
        Int?   approx_num_proteins
        String database_location="/refdata/img/"
        String cath_funfam_db="~{database_location}"+"/Cath-FunFam/v4.2.0/funfam.hmm"
        String container
    }

  call run {
    input:
      project_id = imgap_project_id,
      input_fasta = input_fasta,
      threads = additional_threads,
      par_hmm_inst = par_hmm_inst,
      approx_num_proteins = approx_num_proteins,
      cath_funfam_db = cath_funfam_db,
      container = container
  }

  output {
    File   gff = run.gff
    File   domtblout = run.domtblout
    String hmmsearch_cath_funfam_ver = run.hmmsearch_cath_funfam_ver
    String cath_funfam_db_ver = run.cath_funfam_db_ver
  }
}

task run {
    input {
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   input_fasta
        String cath_funfam_db
        Int    threads = 62
        Int    par_hmm_inst = 15
        Int    approx_num_proteins = 0
        Float  min_domain_eval_cutoff = 0.01
        Float  aln_length_ratio = 0.7
        Float  max_overlap_ratio = 0.1
        String base=basename(input_fasta)
        String container
        String hmmsearch_version_file = "hmmsearch_version.txt"
        String cath_funfam_db_version_file = "cath_funfam_db_version.txt"
    }
  command <<<
    set -euo pipefail
    cp ~{input_fasta} ~{base}
    /opt/omics/bin/functional_annotation/hmmsearch_cath_funfams.sh ~{base} \
    ~{cath_funfam_db} ~{threads} ~{par_hmm_inst} ~{approx_num_proteins} \
    ~{min_domain_eval_cutoff} ~{aln_length_ratio} ~{max_overlap_ratio}

    hmmsearch_version="`hmmsearch -h | grep HMMER | cut -d' ' -f2,3 `"
    echo $hmmsearch_version > ~{hmmsearch_version_file}
    cath_funfam_db_version="Cath-Funfam $(basename $(realpath $(dirname ~{cath_funfam_db})))"
    echo $cath_funfam_db_version > ~{cath_funfam_db_version_file}
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File   gff = "~{prefix}_cath_funfam.gff"
    File   domtblout = "~{prefix}_proteins.cath_funfam.domtblout"
    String hmmsearch_cath_funfam_ver = read_string(hmmsearch_version_file)
    String cath_funfam_db_ver = read_string(cath_funfam_db_version_file)
  }
}
