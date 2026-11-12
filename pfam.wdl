version 1.0

workflow pfam {
    input {
        String imgap_project_id
        File   input_fasta
        Int    additional_threads
        Int?   par_hmm_inst
        Int?   approx_num_proteins
        String database_location="/refdata/img/"
        String pfam_db="~{database_location}"+"/Pfam/37.0/Pfam-A.hmm"
        String pfam_claninfo_tsv="~{database_location}"+"/Pfam/37.0/Pfam-A.clans.tsv"
        String container
    }

  call run {
    input:
      project_id = imgap_project_id,
      input_fasta = input_fasta,
      threads = additional_threads,
      par_hmm_inst = par_hmm_inst,
      approx_num_proteins = approx_num_proteins,
      pfam_db = pfam_db,
      pfam_claninfo_tsv = pfam_claninfo_tsv,
      container = container
  }

  output {
    File   gff = run.gff
    File   domtblout = run.domtblout
    String hmmsearch_pfam_ver = run.hmmsearch_pfam_ver
    String pfam_db_ver = run.pfam_db_ver
  }
}

task run {
    input {
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   input_fasta
        String pfam_db
        String pfam_claninfo_tsv
        Int    threads = 62
        Int    par_hmm_inst = 15
        Int    approx_num_proteins = 0
        String base=basename(input_fasta)
        String container
        String hmmsearch_version_file = "hmmsearch_version.txt"
        String pfam_db_version_file = "pfam_db_version.txt"
    }
  command <<<
    set -euo pipefail
    cp ~{input_fasta} ~{base}

    #Usage: hmmsearch_pfams.sh <proteins_fasta> <pfam_hmm_db> <pfam_claninfo_tsv> <number_of_additional_threads (default: 0)>
    /opt/omics/bin/functional_annotation/hmmsearch_pfams.sh ~{base} \
    ~{pfam_db} ~{pfam_claninfo_tsv} \
    ~{threads} ~{par_hmm_inst} ~{approx_num_proteins}

    hmmsearch_version="`hmmsearch -h | grep HMMER | cut -d' ' -f2,3 `"
    echo $hmmsearch_version > ~{hmmsearch_version_file}
    pfam_db_version="Pfam $(basename $(realpath $(dirname ~{pfam_db})))"
    echo $pfam_db_version > ~{pfam_db_version_file}
  >>>

  runtime {
    time: "1:00:00"
    memory: "86G"
    docker: container
  }

  output {
    File   gff = "~{prefix}_pfam.gff"
    File   domtblout = "~{prefix}_proteins.pfam.domtblout"
    String hmmsearch_pfam_ver = read_string(hmmsearch_version_file)
    String pfam_db_ver = read_string(pfam_db_version_file)
  }
}
