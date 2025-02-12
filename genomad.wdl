version 1.0
workflow jgi_genomad {
    input {
        Boolean genomad_execute = false
        File input_fasta
        String container
        Int len_cutoff = 2000
        String db_dir = "/refdata/genomad_db/"
        Int threads = 1
    }
  
  call run_genomad {
    input:
    genomad_execute = genomad_execute,
    input_fasta = input_fasta,
    container = container,
    len_cutoff = len_cutoff,
    db_dir = db_dir,
    threads = threads
  }

  output {
    File virus_summary = run_genomad.virus_summary
    File plasmid_summary = run_genomad.plasmid_summary
    File aggregated_class = run_genomad.aggregated_class
    File info = run_genomad.std_out
  }
}

task run_genomad {
    input {
        Boolean genomad_execute
        File   input_fasta
        Int    len_cutoff 
        String db_dir 
        Int    threads 
        String container
        String agg_class = "aggregated_classification.tsv"
        String plas_sum = "plasmid_summary.tsv"
        String vir_sum = "virus_summary.tsv"
    }
  command <<<
    set -euo pipefail
    if [[ "~{genomad_execute}" = true ]]
     then 
     echo "starting genomad"
      /usr/local/bin/_entrypoint.sh \
      genomad.sh \
            --len_cutoff ~{len_cutoff} \
            --database_dir ~{db_dir} \
            --threads ~{threads} \
            ~{input_fasta}
      
      # allow for glob / recursive search of files moved by genomad.sh
      shopt -s globstar 
      # file tree should be jgi_genomad/{execution_id}/call-run_genomad/execution/outputs.tsv 
      # if running just genomad.wdl, files end up in call-run_genomad/ instead of in execution/
      mv ../../**/*.tsv . 
      
      # move and rename files output from genomad.sh script so that cromwell can find them
      mv *classification.tsv ~{agg_class}
      mv *plasmid_summary.tsv ~{plas_sum}
      mv *virus_summary.tsv ~{vir_sum}

    else
      echo "skipping genomad"
      echo "NA" > ~{agg_class}
      echo "NA" > ~{plas_sum}
      echo "NA" > ~{vir_sum}
    fi
    echo "container: ~{container}"
    echo "finished run_genomad"
  >>>

  runtime {
    runtime_minutes: "90"
    memory: "86G"
    docker: container
  }

  output {
    File aggregated_class = "~{agg_class}"
    File plasmid_summary = " ~{plas_sum}"
    File virus_summary = "~{vir_sum}"
    File std_out = stdout()
  }
}
