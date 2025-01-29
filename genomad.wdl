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
        String bin="/usr/local/bin/genomad.sh"
        File   input_fasta
        Int    len_cutoff 
        String db_dir 
        Int    threads 
        String container
        String genomad_prefix = basename(input_fasta) + ".filtered"
        String agg_class = "~{genomad_prefix}_aggregated_classification.tsv"
        String plas_sum = "~{genomad_prefix}_plasmid_summary.tsv"
        String vir_sum = "~{genomad_prefix}_virus_summary.tsv"
    }
  command <<<
    set -euo pipefail
    if [[ "~{genomad_execute}" = true ]]
     then 
     echo ~{genomad_prefix}
     echo ~{agg_class}
     echo "starting genomad"
    #  sed -i -e 's/mv/\# mv/g' /usr/local/bin/genomad.sh
    #  cat genomad.sh
      /usr/local/bin/_entrypoint.sh \
      genomad.sh \
            --len_cutoff ~{len_cutoff} \
            --database_dir ~{db_dir} \
            --threads ~{threads} \
            ~{input_fasta}
      
      ls ../../
      mv ../../**/*.tsv .
      
      
      # mv ~{agg_class} .
      # mv ~{plas_sum} .
      # mv ~{vir_sum} .
      # move and rename files output from genomad.sh script so that cromwell can find them
      # mv ../inputs/~{agg_class} ./genomad_aggregated_classification.tsv
      # mv ../inputs/~{plas_sum} ./genomad_plasmid_summary.tsv
      # mv ../inputs/~{vir_sum} ./genomad_virus_summary.tsv

    else
      echo "skipping genomad"
      echo "NA" > ~{agg_class}
      echo "NA" > ~{plas_sum}
      echo "NA" > ~{vir_sum}
    fi
    echo "container: ~{container}"

  >>>

  runtime {
    runtime_minutes: "90"
    memory: "86G"
    docker: container
  }

  output {
    File virus_summary = "~{agg_class}"
    File plasmid_summary = " ~{plas_sum}"
    File aggregated_class = "~{vir_sum}"
    File std_out = stdout()
  }
}
