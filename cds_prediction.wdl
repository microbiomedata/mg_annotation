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
         String prefix=sub(project_id, ":", "_")
         String container
         Int? imgap_structural_annotation_translation_table
         String bin
         String? gm_license
         Boolean genemark_execute
         Boolean prodigal_execute
     }

   command <<<
       set -oeu pipefail

       ln ~{imgap_input_fasta} ~{prefix}_contigs.fna || ln -s ~{imgap_input_fasta} ~{prefix}_contigs.fna

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
       /usr/bin/time ~{bin}/cds_prediction.sh ~{prefix}_contigs.fna ~{imgap_project_type} ~{imgap_structural_annotation_translation_table} &> ~{prefix}_cds.log
       rm ~{prefix}_contigs.fna
   >>>
   

  runtime {
     runtime_minutes: 60
     memory: "86G"
     cpu: 12
     docker: container
   }
  
  output { 
    File genemark_proteins= "~{prefix}_genemark_proteins.faa"
    File genemark_genes= "~{prefix}_genemark_genes.fna"
    File genemark_gff= "~{prefix}_genemark.gff"
    File prodigal_proteins= "~{prefix}_prodigal_proteins.faa"
    File prodigal_genes = "~{prefix}_prodigal_genes.fna"
    File prodigal_gff = "~{prefix}_prodigal.gff"
    File  proteins= "~{prefix}_cds_proteins.faa"
    File  genes= "~{prefix}_cds_genes.fna"
    File  gff= "~{prefix}_cds.gff"
  }

}

