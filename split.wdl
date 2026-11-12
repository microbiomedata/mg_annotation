version 1.0

workflow split {
    input {
        File   infile
        Int    blocksize=100
        String container
    }

  call run {
    input:
      infile = infile,
      blocksize = blocksize,
      container = container
  }

  output {
    Array[File] files = run.files
    String      zscore = run.zscore
    String      cmzscore = run.cmzscore
    String      imgap_version = run.imgap_version
  }
}

task run {
    input {
        File   infile
        Int    blocksize=100
        String zfile="zscore.txt"
        String cmzfile="cmzscore.txt"
        String container
        String imgap_version_file="imgap_version.txt"
    }

  command <<<
    set -euo pipefail
    /opt/omics/bin/split.py ~{infile} ~{blocksize} .
    echo $(egrep -v "^>" ~{infile} | tr -d '\n' | wc -m) / 500 | bc > ~{zfile}
    echo "scale=6; ($(grep -v '^>' ~{infile} | tr -d '\n' | wc -m) * 2) / 1000000" | bc -l > ~{cmzfile}
    cat /opt/omics/VERSION > ~{imgap_version_file}
  >>>

  output {
    Array[File] files = read_lines('splits_out.fof')
    String      zscore = read_string(zfile)
    String      cmzscore = read_string(cmzfile)
    String      imgap_version = read_string(imgap_version_file)
  }

  runtime {
    memory: "120G"
    cpu: 16
    maxRetries: 1
    docker: container
  }
}
