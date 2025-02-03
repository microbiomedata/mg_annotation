FROM debian:bullseye as buildbase

RUN apt-get -y update && apt-get -y install git gcc make wget time autoconf unzip curl ca-certificates

RUN apt-get -y install libz-dev
#
# Build prodigal
#
FROM buildbase as prodigal
#4/20/23 Marcel is using a patched version, get from NERSC instead of offical repo
RUN \
    cd /opt && \
    wget http://portal.nersc.gov/dna/metagenome/assembly/prodigal_2.6.3_patched/prodigal && \
    chmod 755 prodigal

#RUN git clone --branch v2.6.3 https://github.com/hyattpd/Prodigal

#RUN cd Prodigal  && make install

#RUN cd Prodigal && make install


# Build trnascan 2.0.08
#
FROM buildbase as trnascan

RUN wget http://trna.ucsc.edu/software/trnascan-se-2.0.12.tar.gz

RUN \
    tar xzvf trnascan-se-2.0.12.tar.gz && \
    cd tRNAscan-SE-2.0 && \
    ./configure --prefix=/opt/omics/programs/tRNAscan-SE/tRNAscan-SE-2.0.12/ && \
    make && make install

#
# Build HMMER 3.1b2 with HPC enhancements from Arndt
#
FROM buildbase as hmm

ENV V=3.1b2
RUN \
    cd /opt && \
    wget http://eddylab.org/software/hmmer/hmmer-$V.tar.gz && \
    tar -zxvf hmmer-$V.tar.gz && \
    cd hmmer-$V && ./configure --prefix /opt/omics/programs/hmmer/ && \
    make && make install

# get and extract commit sha a8d641046729328fdda97331d527edb2ce81510a  of master branch of modification file, copy into hmmer source code
RUN \
    wget https://github.com/Larofeticus/hpc_hmmsearch/archive/a8d641046729328fdda97331d527edb2ce81510a.zip && \
    unzip a8d641046729328fdda97331d527edb2ce81510a.zip && \
    cp /hpc_hmmsearch-*/hpc_hmmsearch.c /opt/hmmer-3.1b2/src && \
    cd /opt/hmmer-$V/src && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -fopenmp -fPIC -msse2 -DHAVE_CONFIG_H -I../easel -I../libdivsufsort -I../easel -I. -I. -o hpc_hmmsearch.o -c hpc_hmmsearch.c && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -fopenmp -fPIC -msse2 -DHAVE_CONFIG_H -L../easel -L./impl_sse -L../libdivsufsort -L. -o hpc_hmmsearch hpc_hmmsearch.o -lhmmer -leasel -ldivsufsort -lm  && \
   cp hpc_hmmsearch /opt/omics/programs/hmmer/bin/ && \
   /opt/omics/programs/hmmer/bin/hpc_hmmsearch -h
# Build last 1584
#
FROM buildbase as last

RUN apt-get -y install  g++

RUN \
    git clone --depth 1 --branch 1584 https://gitlab.com/mcfrith/last && \
    cd last && \
    make && \
    make prefix=/opt/omics/programs/last install

# Build infernal 1.1.3
#
FROM buildbase as infernal

RUN \
    wget http://eddylab.org/infernal/infernal-1.1.3.tar.gz && \
    tar xzf infernal-1.1.3.tar.gz

RUN \
    cd infernal-1.1.3 && \
    ./configure --prefix=/opt/omics/programs/infernal/infernal-1.1.3 && \
    make && make install

#
# IMG scripts and tools v 5.1.14, repo is public 4/2023. Add split.py from bfoster1/img-omics:0.1.12 (md5sum 21fb20bf430e61ce55430514029e7a83)
#
FROM buildbase as img

RUN \
    cd /opt && \
    git clone -b scaffold-lineage https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline

RUN \
   cd /opt && \
   curl https://code.jgi.doe.gov/official-jgi-workflows/jgi-wdl-pipelines/img-omics/-/raw/83c5483f0fd8afc43a2956ed065bffc08d8574da/bin/split.py > split.py && \
   chmod 755 split.py

# MetaGeneMark version was updated for img annotation pipeline 5.1.*


RUN \
    cd /opt && \
    wget http://portal.nersc.gov/dna/metagenome/assembly/gms2_linux_64.v1.14_1.25_lic.tar.gz && \
    tar -zxvf gms2_linux_64.v1.14_1.25_lic.tar.gz && \
    #chmod -R 755 omics && \
    rm gms2_linux_64.v1.14_1.25_lic.tar.gz

RUN apt-get update && apt-get install -y openjdk-11-jdk
# get CRT version 1.8.4
RUN \
    wget https://code.jgi.doe.gov/img/img-pipelines/crt-cli-imgap-version/-/archive/main/crt-cli-imgap-version-main.zip && \
    unzip crt-cli-imgap-version-main.zip && \
    cd crt-cli-imgap-version-main && \
    javac *.java && \
    jar cfe CRT-CLI.jar crt *.class && \
    cp CRT-CLI.jar /opt/.



#
# Build the final image
#
FROM buildbase as conda

# Install Miniconda
#
RUN \
    wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash ./Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda3

ENV PATH /miniconda3/bin:/miniconda3/condabin:$PATH

RUN conda config --add channels conda-forge && conda config --add channels bioconda  && conda config --add channels anaconda

RUN conda install -y curl git wget jq parallel pyyaml openjdk perl-getopt-long bc procps-ng

RUN conda clean -y -a

#
# Install Cromwell v49
#
FROM buildbase as cromwell

RUN \
    mkdir -p /opt/omics/bin && \
    cd /opt/omics/bin && \
    wget -q https://github.com/broadinstitute/cromwell/releases/download/49/cromwell-49.jar && \
    ln -sf cromwell-49.jar cromwell.jar

FROM buildbase

ENV PERL5LIB '/opt/omics/lib'
COPY --from=conda /miniconda3 /miniconda3

# conda shell.posix activate
ENV  PATH '/miniconda3/bin:/miniconda3/condabin:/opt/omics/bin:/opt/omics/bin/functional_annotation:/opt/omics/bin/qc/post-annotation:/opt/omics/bin/qc/pre-annotation:/opt/omics/bin/structural_annotation:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
ENV  CONDA_PREFIX '/miniconda3'
ENV  CONDA_EXE '/miniconda3/bin/conda'
ENV  _CE_M ''
ENV  _CE_CONDA ''
ENV  CONDA_PYTHON_EXE '/miniconda3/bin/python'

COPY --from=cromwell /opt/omics/bin/ /opt/omics/bin/

COPY --from=prodigal /opt/prodigal /opt/omics/programs/prodigal

COPY --from=trnascan /opt/omics/programs/tRNAscan-SE /opt/omics/programs/tRNAscan-SE
#COPY --from=trnascan /usr/local/lib /opt/omics/programs/tRNAscan-SE/tRNAscan-SE-2.0.12/lib/

COPY --from=hmm /opt/omics/programs/hmmer/ /opt/omics/programs/hmmer
COPY --from=last /opt/omics/programs/last/ /opt/omics/programs/last

COPY --from=last /opt/omics/programs/last /opt/omics/programs/last
COPY --from=img /opt/CRT-CLI.jar /opt/omics/programs/CRT/CRT-CLI.jar
COPY --from=img /opt/split.py /opt/omics/bin/split.py
#COPY --from=img /opt/omics/programs/tmhmm-2.0c /opt/omics/programs/tmhmm-2.0c

COPY --from=infernal /opt/omics/programs/infernal /opt/omics/programs/infernal/
COPY --from=img /opt/img-annotation-pipeline/bin/ /opt/omics/bin/
COPY --from=img /opt/gms2_linux_64 /opt/omics/programs/gms2_linux_64
COPY --from=img /opt/img-annotation-pipeline/VERSION /opt/omics/VERSION
RUN \
    mkdir /opt/omics/lib && cd /opt/omics/lib && \
    ln -s ../programs/tRNAscan-SE/tRNAscan-SE-2.0.12/lib/tRNAscan-SE/* . 

#link things to the bin directory

RUN \
    cd /opt/omics/bin &&\ 
    ln -s ../programs/gms2_linux_64/gms2.pl &&\
    ln -s ../programs/gms2_linux_64/gmhmmp2 &&\
    ln -s ../programs/infernal/infernal-1.1.3/bin/cmsearch && \
    ln -s ../programs/tRNAscan-SE/tRNAscan-SE-2.0.12/bin/tRNAscan-SE && \
    ln -s ../programs/last/bin/lastal && \
    ln -s ../programs/CRT/CRT-CLI.jar CRT-CLI.jar && \
    ln -s ../programs/prodigal &&\
    ln -s ../programs/hmmer/bin/hpc_hmmsearch /opt/omics/bin/hmmsearch 

#make sure tRNAscan can see cmsearch and cmscan

RUN \ 
    cd /opt/omics/programs/tRNAscan-SE/tRNAscan-SE-2.0.12/bin/ &&\
    ln -s /opt/omics/programs/infernal/infernal-1.1.3/bin/cmsearch && \
    ln -s /opt/omics/programs/infernal/infernal-1.1.3/bin/cmscan

#COPY --from=img /opt/omics /opt/omics3/

