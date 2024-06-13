import "annotation_full.wdl" as awf

workflow test_small {
  String  container="microbiomedata/img-omics@sha256:d5f4306bf36a97d55a3710280b940b89d7d4aca76a343e75b0e250734bc82b71"
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
           input_file=prepare.fasta,
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
   String prefix = sub(proj, ":", "_")
   String url

   command{
       wget ${url}/${prefix}_contigs.fna
   }

   output{
      File fasta = "${prefix}_contigs.fna"
   }
   runtime {
     memory: "1G"
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
   String prefix = sub(proj, ":", "_")

   command{
       set -e
       wget ${url}/${prefix}_functional_annotation.gff
       wget ${url}/${prefix}_structural_annotation.gff
       validate.sh ${func_gff}
       validate.sh ${struct_gff}
   }

   runtime {
     memory: "10G"
     cpu:  4
     maxRetries: 1
     docker: "microbiomedata/mg-validate:v0.0.0"
   }
}


