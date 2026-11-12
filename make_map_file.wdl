version 1.0

workflow make_map_file {
    input {
        String proj_id
        File   input_file
        String container
        Int    min_seq_length = 150      # default value
        Int    unknown_gap_length = 100  # default value
    }

  call run {
    input:
      proj_id = proj_id,
      input_file = input_file,
      container = container,
      min_seq_length = min_seq_length,
      unknown_gap_length = unknown_gap_length
  }

  output {
    File map_file = run.map_file
    File out_fasta = run.out_fasta
    File out_log = run.out_log
  }
}

task run {
    input {
        String proj_id
        String prefix=sub(proj_id, ":", "_")
        File   input_file
        String container
        Int    min_seq_length = 150      # default value
        Int    unknown_gap_length = 100  # default value
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

  output {
    File map_file = "~{prefix}_contig_names_mapping.tsv"
    File out_fasta = "~{prefix}_map.fasta"
    File out_log = stdout()
  }

  runtime {
    memory: "120G"
    cpu: 16
    maxRetries: 1
    docker: container
  }
}
