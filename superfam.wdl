version 1.0

workflow superfam {
    input {
        String imgap_project_id
        File   input_fasta
        Int    additional_threads
        Int?   par_hmm_inst
        Int?   approx_num_proteins
        String database_location="/refdata/img/"
        String superfam_db="~{database_location}"+"/SuperFamily/v1.75/supfam.hmm"
        String container
    }

  call run {
    input:
      project_id = imgap_project_id,
      input_fasta = input_fasta,
      threads = additional_threads,
      par_hmm_inst = par_hmm_inst,
      approx_num_proteins = approx_num_proteins,
      superfam_db = superfam_db,
      container = container
  }

  output {
    File   gff = run.gff
    File   domtblout = run.domtblout
    String hmmsearch_superfam_ver = run.hmmsearch_superfam_ver
    String superfam_db_ver = run.superfam_db_ver
  }
}

task run {
    input {
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   input_fasta
        String superfam_db
        Int    threads = 62
        Int    par_hmm_inst = 15
        Int    approx_num_proteins = 0
        Float  min_domain_eval_cutoff = 0.01
        Float  aln_length_ratio = 0.7
        Float  max_overlap_ratio = 0.1
        String base=basename(input_fasta)
        String container
        String hmmsearch_version_file = "hmmsearch_version.txt"
        String superfam_db_version_file = "superfam_db_version.txt"
    }
  command <<<
    set -euo pipefail
    cp ~{input_fasta} ~{base}
    #Usage: hmmsearch_supfams.sh <proteins_fasta> <supfam_hmm_db> <number_of_additional_threads (default: 0)> <number_of_parallel_hmmsearch_instances (default: 0)> <approximate_number_of_total_proteins (default: 0)> <min_domain_evalue_cutoff (default 0.01)> <min_aln_length_ratio (default 0.7)> <max_overlap_ratio (default 0.1)>

    /opt/omics/bin/functional_annotation/hmmsearch_supfams.sh ~{base} \
    ~{superfam_db} \
    ~{threads} ~{par_hmm_inst} ~{approx_num_proteins} \
    ~{min_domain_eval_cutoff} ~{aln_length_ratio} ~{max_overlap_ratio}

    hmmsearch_version="`hmmsearch -h | grep HMMER | cut -d' ' -f2,3 `"
    echo $hmmsearch_version > ~{hmmsearch_version_file}
    superfam_db_version="SuperFamily $(basename $(realpath $(dirname ~{superfam_db})))"
    echo $superfam_db_version > ~{superfam_db_version_file}
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File   gff = "~{prefix}_supfam.gff"
    File   domtblout = "~{prefix}_proteins.supfam.domtblout"
    String hmmsearch_superfam_ver = read_string(hmmsearch_version_file)
    String superfam_db_ver = read_string(superfam_db_version_file)
  }
}
