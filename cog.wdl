version 1.0

workflow cog {
    input {
        String imgap_project_id
        File   input_fasta
        Int    additional_threads
        Int?   par_hmm_inst
        Int?   approx_num_proteins
        String database_location="/refdata/img/"
        String cog_db="~{database_location}"+"/COG/2014/COG.hmm"
        String container
    }

  call run {
    input:
      project_id = imgap_project_id,
      input_fasta = input_fasta,
      threads = additional_threads,
      par_hmm_inst = par_hmm_inst,
      approx_num_proteins = approx_num_proteins,
      cog_db = cog_db,
      container = container
  }

  output {
    File   gff = run.gff
    File   domtblout = run.domtblout
    String hmmsearch_cog_ver = run.hmmsearch_cog_ver
    String cog_db_ver = run.cog_db_ver
  }
}

task run {
    input {
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   input_fasta
        String cog_db
        Int    threads = 62
        Int    par_hmm_inst = 15
        Int    approx_num_proteins = 0
        Float  min_domain_eval_cutoff = 0.01
        Float  aln_length_ratio = 0.7
        Float  max_overlap_ratio = 0.1
        String base=basename(input_fasta)
        String container
        String hmmsearch_version_file = "hmmsearch_version.txt"
        String cog_db_version_file = "cog_db_version.txt"
    }
  command <<<
    set -euo pipefail
    cp ~{input_fasta} ~{base}
    /opt/omics/bin/functional_annotation/hmmsearch_cogs.sh ~{base} \
    ~{cog_db} \
    ~{threads} ~{par_hmm_inst} ~{approx_num_proteins} \
    ~{min_domain_eval_cutoff} ~{aln_length_ratio} ~{max_overlap_ratio}

    #get versions
    hmmsearch_version="`hmmsearch -h | grep HMMER | cut -d' ' -f2,3`"
    echo $hmmsearch_version > ~{hmmsearch_version_file}
    cog_db_version="COG $(basename $(realpath $(dirname ~{cog_db})))"
    echo $cog_db_version > ~{cog_db_version_file}
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File   gff = "~{prefix}_cog.gff"
    File   domtblout = "~{prefix}_proteins.cog.domtblout"
    String hmmsearch_cog_ver = read_string(hmmsearch_version_file)
    String cog_db_ver = read_string(cog_db_version_file)
  }
}
