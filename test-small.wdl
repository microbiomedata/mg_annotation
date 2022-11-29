import "annotation_full.wdl" as awf

workflow test_small {
  String  container="bfoster1/img-omics:0.1.7"
  String  proj="Testsmall"
  String  database="/refdata/img/"
  String  url="https://portal.nersc.gov/project/m3408/test_data"

  call prepare {
    input: container=container,
           url=url,
           proj=proj
  }
  call awf.annotation {
    input: imgap_project_id=proj,
           imgap_input_fasta=prepare.fasta,
           database_location=database
  }
  call validate {
    input: container=container,
           url=url,
           proj=proj,
           func_gff=annotation.functional_gff,
           struct_gff=annotation.structural_gff
  }

  meta {
    author: "Shane Canon"
    email: "scanon@lbl.gov"
    version: "1.0.0"
  }
}

task prepare {
   String container
   String proj
   String url

   command{
       wget ${url}/${proj}_contigs.fna
   }

   output{
      File fasta = "${proj}_contigs.fna"
   }
   runtime {
     memory: "1 GiB"
     cpu:  2
     maxRetries: 1
     docker: container
   }
}


task validate {
   String container
   File   func_gff
   File   struct_gff
   String url
   String proj

   command{
       set -e
       wget ${url}/${proj}_functional_annotation.gff
       wget ${url}/${proj}_structural_annotation.gff
       validate.sh ${func_gff}
       validate.sh ${struct_gff}
   }

   runtime {
     memory: "10 GiB"
     cpu:  4
     maxRetries: 1
     docker: "microbiomedata/mg-validate:v0.0.0"
   }
}


