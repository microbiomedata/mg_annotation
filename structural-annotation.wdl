version 1.0

import "trnascan.wdl" as trnascan
import "rfam.wdl" as rfam
import "crt.wdl" as crt
import "cds_prediction.wdl" as cds_prediction

workflow s_annotate {
    input {
      String  cmzscore
      File    imgap_input_fasta
      String  imgap_project_id
      String  imgap_project_type
      Int     additional_threads
      Int     additional_memory
      Int? imgap_structural_annotation_translation_table
      String  database_location
      String  container
      String gm_license="/refdata/licenses/.gmhmmp2_key"
    }

    # call pre_qc {
    #   input:
    #     project_type = imgap_project_type,
    #     input_fasta = imgap_input_fasta,
    #     project_id = imgap_project_id,
    #     container=container
    # }


    call trnascan.trnascan as ts{
      input:
        imgap_input_fasta = imgap_input_fasta,
        imgap_project_id = imgap_project_id,
        additional_threads = additional_threads,
        container=container
    }


    call rfam.rfam as rf{
      input:
        cmzscore = cmzscore,
        imgap_input_fasta = imgap_input_fasta,
        imgap_project_id = imgap_project_id,
        database_location = database_location,
        additional_threads = additional_threads,
        container=container,
        additional_memory = additional_memory
    }


    call crt.crt as ct {
      input:
        imgap_input_fasta = imgap_input_fasta,
        imgap_project_id = imgap_project_id,
        container=container
    }



     call cds_prediction.cds_prediction as cds{
       input:
         imgap_input_fasta = imgap_input_fasta,
         imgap_project_id = imgap_project_id,
         imgap_project_type = imgap_project_type,
         imgap_structural_annotation_translation_table = imgap_structural_annotation_translation_table,
         container = container,
         gm_license = gm_license
    }



    call gff_merge {
      input:
        input_fasta = imgap_input_fasta,
        project_id = imgap_project_id,
        rfam_gff = rf.rfam_gff,
        trna_gff = ts.gff,
        crt_gff = ct.gff,
        cds_gff = cds.gff,
        container = container
    }

    call fasta_merge {
      input:
       # input_fasta = imgap_input_fasta,
        project_id = imgap_project_id,
        final_gff = gff_merge.final_gff,
        cds_genes = cds.genes,
        cds_proteins = cds.proteins,
        container = container
    }



    call gff_and_fasta_stats {
      input:
        input_fasta = imgap_input_fasta,
        final_gff = gff_merge.final_gff,
        container = container
    }




  output {
    File  gff = gff_merge.final_gff 
    File crt_gff = ct.gff
    File crisprs = ct.crisprs
    File crt_out = ct.crt_out
    File genemark_gff = cds.genemark_gff
    File genemark_genes = cds.genemark_genes
    File genemark_proteins = cds.genemark_proteins
    File prodigal_gff = cds.prodigal_gff
    File prodigal_genes = cds.prodigal_genes
    File prodigal_proteins = cds.prodigal_proteins
    File cds_gff = cds.gff
    File cds_proteins = cds.proteins
    File cds_genes = cds.genes
    File trna_gff = ts.gff
    File trna_bacterial_out = ts.bacterial_out
    File trna_archaeal_out = ts.archaeal_out
    File rfam_gff = rf.rfam_gff
    File rfam_tbl = rf.rfam_tbl
    String rfam_version = rf.rfam_version
    File proteins = fasta_merge.final_proteins
    File genes = fasta_merge.final_genes
  }
}

task pre_qc {
    input {
        String bin="/opt/omics/bin/qc/pre-annotation/fasta_sanity.py"
        String project_type
        File   input_fasta
        String project_id
        String prefix=sub(project_id, ":", "_")
        Float  n_ratio_cutoff = 0.5
        Int    seqs_per_million_bp_cutoff = 500
        Int    min_seq_length = 150
        String container
        String tmp_fasta="~{input_fasta}.tmp"
        String qced_fasta="~{prefix}_contigs.fna"
    }

  command <<<
    set -euo pipefail
    echo ~{tmp_fasta}
    grep -v '^\s*$' ~{input_fasta} | tr -d '\r' | \
    sed 's/^>[[:blank:]]*/>/g' > ~{tmp_fasta}
    acgt_count=`grep -v '^>' ~{tmp_fasta} | grep -o [acgtACGT] | wc -l`
    n_count=`grep -v '^>' ~{tmp_fasta} | grep -o '[^acgtACGT]' | wc -l`
    n_ratio=`echo ~n_count $acgt_count | awk '{printf "%f", $1 / $2}'`
    if (( $(echo "~n_ratio >= ~{n_ratio_cutoff}" | bc) ))
    then
        rm ~{tmp_fasta}
        exit 1
    fi

    if [[ ~{project_type} == "isolate" ]]
    then
        seq_count=`grep -c '^>' ~{tmp_fasta}`
        bp_count=`grep -v '^>' ~{tmp_fasta} | tr -d '\n' | wc -m`
        seqs_per_million_bp=$seq_count
        if (( $bp_count > 1000000 ))
        then
            divisor=$(echo ~bp_count | awk '{printf "%.f", $1 / 1000000}')
            seqs_per_million_bp=$(echo ~seq_count $divisor | \
                                  awk '{printf "%.2f", $1 / $2}')
        fi
        if (( $(echo "~seqs_per_million_bp > ~{seqs_per_million_bp_cutoff}" | bc) ))
        then
            rm ~{tmp_fasta}
            exit 1
        fi
    fi
    ~{bin} -v
    ~{bin} ~{tmp_fasta} ~{qced_fasta} -l ~{min_seq_length}
    rm ~{tmp_fasta}
  >>>

  runtime {
    runtime_minutes: 60
    memory: "64G"
    cpu: 8
    docker: container
  }

  output {
    File fasta = "~{prefix}_contigs.fna"
    File  out_log = stdout()
  }
}

task gff_merge {
    input {
        String bin="/opt/omics/bin/structural_annotation/gff_files_merger.py"
        File   input_fasta
        String project_id
        String prefix=sub(project_id, ":", "_")
        # File  rrna_gff
        File  trna_gff
        File  rfam_gff
        File  crt_gff
        File  cds_gff
        String container
  }
  command <<<
    set -euo pipefail

    ~{bin} \
      --contigs_fasta ~{input_fasta} \
      --cds_gff ~{cds_gff} \
      --crt_gff ~{crt_gff} \
      --log_file ~{prefix}_gff_merge.log \
      ~{rfam_gff} \
      ~{trna_gff} \
     1> ~{prefix}_structural_annotation.gff


  >>>

  runtime {
    runtime_minutes: 60
    memory: "64G"
    cpu: 8
    docker: container
  }

  output {
    File final_gff = "~{prefix}_structural_annotation.gff"
  }
}

task fasta_merge {
    input {
        String bin="/opt/omics/bin/structural_annotation/finalize_fasta_files.py"
        String project_id
        String prefix=sub(project_id, ":", "_")
        File   final_gff
        File cds_genes
        File cds_proteins
        String genes_filename = basename(cds_genes)
        String proteins_filename = basename(cds_proteins)
        String container
    }
  command <<<
   set -euo pipefail
   cp ~{final_gff} .
   cp ~{cds_genes} .
   cp ~{cds_proteins} .
   ~{bin} ~{final_gff} ~{genes_filename} ~{proteins_filename}
  >>>

  runtime {
    runtime_minutes: 60
    memory: "40G"
    cpu: 8
    docker: container
  }
 
  output {
    File final_genes = "~{prefix}_genes.fna"
    File final_proteins = "~{prefix}_proteins.faa"
  }
}

task gff_and_fasta_stats {
    input {
        String bin="/opt/omics/bin/structural_annotation/gff_and_final_fasta_stats.py"
        File   input_fasta
        File   final_gff
        String container
    }
  command <<<
    set -euo pipefail
    ~{bin} ~{input_fasta} ~{final_gff}
  >>>

  runtime {
    runtime_minutes: 60
    memory: "86G"
    cpu: 8
    docker: container
  }

}

task post_qc {
    input {
        String qc_bin="/opt/omics/bin/qc/post-annotation/genome_structural_annotation_sanity.py"
        File   input_fasta
        String project_id
        String prefix=sub(project_id, ":", "_")
        String container
    }
  command <<<
  set -euo pipefail
    ~{qc_bin} ~{input_fasta} "~{prefix}_structural_annotation.gff"
  >>>

  runtime {
    runtime_minutes: 60
    memory: "86G"
    cpu: 8
    docker: container
  }
 
  output {
    File out = "~{prefix}_structural_annotation.gff"
  }
}
