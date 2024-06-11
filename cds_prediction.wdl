version 1.0
workflow cds_prediction {
    input{
        File imgap_input_fasta
        String imgap_project_type
        String imgap_project_id
        String container
        Boolean prodigal_execute=true
        Boolean genemark_execute=true
        Int? imgap_structural_annotation_translation_table
        String bin="/opt/omics/bin/structural_annotation"
        #if running w/JAWS $HOME is not mounted so need the license file in the execution dir
        String? gm_license
    }
    call run_cds_prediction  {
       input: 
           imgap_input_fasta = imgap_input_fasta,
           imgap_project_type=imgap_project_type,
           container=container,
           imgap_structural_annotation_translation_table=imgap_structural_annotation_translation_table,
           bin=bin,
           project_id=imgap_project_id,
           gm_license=gm_license,
           prodigal_execute=prodigal_execute,
           genemark_execute=genemark_execute
    }


  output {
     File genemark_proteins = run_cds_prediction.genemark_proteins
     File genemark_genes = run_cds_prediction.genemark_genes
     File genemark_gff = run_cds_prediction.genemark_gff
     File prodigal_proteins = run_cds_prediction.prodigal_proteins
     File prodigal_genes = run_cds_prediction.prodigal_genes
     File prodigal_gff = run_cds_prediction.prodigal_gff
     File proteins = run_cds_prediction.proteins
     File genes = run_cds_prediction.genes
     File gff = run_cds_prediction.gff
    
  }
  meta {
     author: "Alicia Clum"
     email: "aclum@lbl.gov"
     version: "1.0.0"
  }
}

task run_cds_prediction {
     input{
         File imgap_input_fasta
         String imgap_project_type
         String project_id
         String container
         Int? imgap_structural_annotation_translation_table
         String bin
         String? gm_license
         Boolean genemark_execute
         Boolean prodigal_execute
     }

   command <<<
       set -oeu pipefail

       ln ~{imgap_input_fasta} ~{project_id}_contigs.fna || ln -s ~{imgap_input_fasta} ~{project_id}_contigs.fna

       if [[ "~{prodigal_execute}" = true ]] ; then
           export imgap_structural_annotation_prodigal_execute="True"
       else
           export imgap_structural_annotation_prodigal_execute="False"
       fi
       if [[ "~{genemark_execute}" = true ]] ; then
        export imgap_structural_annotation_genemark_execute="True"
        else
        export imgap_structural_annotation_genemark_execute="False"
       fi 
       #copy genemark license to the execution dir
       cp ~{gm_license} .
       /usr/bin/time ~{bin}/cds_prediction.sh ~{project_id}_contigs.fna ~{imgap_project_type} ~{imgap_structural_annotation_translation_table} &> ~{project_id}_cds.log
       rm ~{project_id}_contigs.fna
   >>>
   

  runtime {
     time: "1:00:00"
     memory: "86G"
     docker: container
   }
  
  output { 
    File genemark_proteins= "~{project_id}_genemark_proteins.faa"
    File genemark_genes= "~{project_id}_genemark_genes.fna"
    File genemark_gff= "~{project_id}_genemark.gff"
    File prodigal_proteins= "~{project_id}_prodigal_proteins.faa"
    File prodigal_genes = "~{project_id}_prodigal_genes.fna"
    File prodigal_gff = "~{project_id}_prodigal.gff"
    File  proteins= "~{project_id}_cds_proteins.faa"
    File  genes= "~{project_id}_cds_genes.fna"
    File  gff= "~{project_id}_cds.gff"
  }

}

