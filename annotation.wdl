#import "https://portal.nersc.gov/project/m3408/wdl/structural-annotation.wdl" as sa
#import "https://portal.nersc.gov/project/m3408/wdl/functional-annotation.wdl" as fa
import "structural-annotation.wdl" as sa
import "functional-annotation.wdl" as fa

workflow annotation {
  String  imgap_input_file
  String  imgap_project_id
  Int     additional_threads=72

  call setup {
    input:
      file = imgap_input_file
  }

  scatter(split in setup.splits) {

    call sa.s_annotate {
      input:
        imgap_project_id = imgap_project_id,
        additional_threads = additional_threads,
        imgap_input_fasta = split
    }

    call fa.f_annotate {
      input:
        imgap_project_id = imgap_project_id,
        additional_threads = additional_threads,
        sa_gff = s_annotate.gff,
        input_fasta = s_annotate.proteins
    }
  }
  call merge_outputs {
    input:
       project_id = imgap_project_id,
       structural_gffs=s_annotate.gff,
       functional_gffs=f_annotate.gff,
       ko_tsvs = f_annotate.ko_tsv,
       ec_tsvs = f_annotate.ec_tsv,
       phylo_tsvs =  f_annotate.phylo_tsv

  }

}

task setup {
  String file

  command {
    python <<CODE
    import os
    chunksize = 10*1024*1024

    infile = "${file}"
    chunk = 1

    fin = open(infile)

    done = False
    while not done:
       outf = '%s.%d' % (os.path.basename(infile), chunk)
       print(outf)
       fout = open(outf, 'w')
       data = fin.read(chunksize)
       fout.write(data)
       if len(data) < chunksize:
           done = True
       while True:
          line = fin.readline()
          if line.startswith('>') or len(line)==0:
             fin.seek(fin.tell()-len(line), 0)
             break
          fout.write(line)
       chunk += 1

    CODE
    }

  output {
    Array[File] splits = read_lines(stdout())
  }
}

task merge_outputs {
  String  project_id
  Array[File] structural_gffs
  Array[File] functional_gffs
  Array[File] ko_tsvs
  Array[File] ec_tsvs
  Array[File] phylo_tsvs

  command {
      cat ${sep=" " structural_gffs} > "${project_id}_structural_annotation.gff"
      cat ${sep=" " functional_gffs} > "${project_id}_functional_annotation.gff"
      cat ${sep=" " ko_tsvs} >  "${project_id}_ko.tsv"
      cat ${sep=" " ec_tsvs} >  "${project_id}_ec.tsv"
      cat ${sep=" " phylo_tsvs} > "${project_id}_gene_phylogeny.tsv"
  }
  output {
    File functional_gff = "${project_id}_structural_annotation.gff"
    File structural_gff = "${project_id}_functional_annotation.gff"
    File ko_tsv = "${project_id}_ko.tsv"
    File ec_tsv = "${project_id}_ec.tsv"
    File phylo_tsv = "${project_id}_gene_phylogeny.tsv"
  }

}

