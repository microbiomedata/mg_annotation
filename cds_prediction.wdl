workflow cds_prediction {

  File imgap_input_fasta
  String fasta_filename = basename(imgap_input_fasta)
  String imgap_project_type
  String container
  Boolean? prodigal=true
  Boolean? genemark=false
  String prodigal_execute_true = "export imgap_structural_annotation_prodigal_execute=\"True\"" 
  String prodigal_execute_false = "export imgap_structural_annotation_prodigal_execute=\"False\""
  String genemark_execute_true = "export imgap_structural_annotation_genemark_execute=\"True\""
  String genemark_execute_false = "export imgap_structural_annotation_genemark_execute=\"False\"" 
  Int? imgap_structural_annotation_translation_table
  String bin="/opt/omics/bin/structural_annotation"

#run both prodigal and genemark

   if (prodigal && genemark) {
    call run_cds_prediction as cds_prodigal_genemark {
       input: imgap_input_fasta=imgap_input_fasta,
           imgap_project_type=imgap_project_type,
           container=container,
           imgap_structural_annotation_translation_table=imgap_structural_annotation_translation_table,
           bin=bin,
           prodigal_execute=prodigal_execute_true,
           genemark_execute=genemark_execute_true,
           fasta_filename=fasta_filename
    }
   }

#run prodigal only
   if (prodigal && !genemark)  {
    call run_cds_prediction  as cds_prodigal {
       input: imgap_input_fasta=imgap_input_fasta,
           imgap_project_type=imgap_project_type,
           container=container,
           imgap_structural_annotation_translation_table=imgap_structural_annotation_translation_table,
           bin=bin,
           prodigal_execute=prodigal_execute_true,
           genemark_execute=genemark_execute_false,
           fasta_filename=fasta_filename
    }
   }

  
#run genemark only
   if (!prodigal && genemark)  {
    call run_cds_prediction as cds_genemark {
       input: imgap_input_fasta=imgap_input_fasta,
           imgap_project_type=imgap_project_type,
           container=container,
           imgap_structural_annotation_translation_table=imgap_structural_annotation_translation_table,
           bin=bin,
           genemark_execute=genemark_execute_true,
           prodigal_execute=prodigal_execute_false,
           fasta_filename=fasta_filename
    }
   }

  output {
    File? genemark_proteins= "${fasta_filename}_genemark_proteins.faa"
    File? genemark_genes= "${fasta_filename}_genemark_genes.fna"
    File? genemark_gff= "${fasta_filename}_genemark.gff"
    File? prodigal_proteins= "${fasta_filename}_prodigal.gff"
    File? prodigal_genes = "${fasta_filename}_prodigal_genes.fna"
    File? prodigal_gff = "${fasta_filename}_prodigal.gff"
    File  proteins= "${fasta_filename}_proteins.faa"
    File  genes= "${fasta_filename}_genes.fna"
    File  gff= "${fasta_filename}_cds.gff"
  }

}

task run_cds_prediction {
   File imgap_input_fasta
   String fasta_filename
   String imgap_project_type
   String container
   Int? imgap_structural_annotation_translation_table
   String bin
   String dollar="$"
   String prodigal_execute
   String genemark_execute


   command {
       set -oeu pipefail
       #set name for log, code needs fasta to be in working dir, set varaiables, run cds_prediction.sh  
       #fasta_filename=${dollar}(basename -- ${imgap_input_fasta})
       cds_log=${fasta_filename}_cds.log
       #cds_log+=_cds.log
       cp ${imgap_input_fasta} . 
       ${prodigal_execute}
       ${genemark_execute}

       /usr/bin/time ${bin}/cds_prediction.sh ${fasta_filename} ${imgap_project_type} ${imgap_structural_annotation_translation_table} &> $cds_log
   }
   

  runtime {
     time: "1:00:00"
     memory: "86G"
     docker: container
   }
  
  output { 
    File? genemark_proteins= "${fasta_filename}_genemark_proteins.faa"
    File? genemark_genes= "${fasta_filename}_genemark_genes.fna"
    File? genemark_gff= "${fasta_filename}_genemark.gff"
    File? prodigal_proteins= "${fasta_filename}_prodigal.gff"
    File? prodigal_genes = "${fasta_filename}_prodigal_genes.fna"
    File? prodigal_gff = "${fasta_filename}_prodigal.gff"
    File  proteins= "${fasta_filename}_proteins.faa"
    File  genes= "${fasta_filename}_genes.fna"
    File  gff= "${fasta_filename}_cds.gff"
  }

}

