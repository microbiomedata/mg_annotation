FROM debian as buildbase

RUN apt-get -y update && apt-get -y install git gcc make wget time autoconf unzip

RUN apt-get -y install libz-dev
#
# Build prodigal
#
FROM buildbase as prodigal

RUN git clone --branch v2.6.3 https://github.com/hyattpd/Prodigal

RUN cd Prodigal  && make install

#RUN cd Prodigal && make install


# Build trnascan 2.0.08
#
FROM buildbase as trnascan

RUN wget http://trna.ucsc.edu/software/trnascan-se-2.0.8.tar.gz

RUN \
    tar xzvf trnascan-se-2.0.8.tar.gz && \
    cd tRNAscan-SE-2.0 && \
    ./configure --prefix=/opt/omics/programs/tRNAscan-SE/tRNAscan-SE-2.0.8/ && \
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
# Build last 1256
#
FROM buildbase as last

RUN apt-get -y install  g++

RUN \
    git clone --depth 1 --branch 1256  https://gitlab.com/mcfrith/last

RUN \
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
# IMG scripts and tools, rm 2019 bin dir, replace with commit 238f6a4b from (https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline/-/commit/238f6a4b092862a2dac33b173dad01f629da0ac1) v 5.1.13. Add split.py from bfoster1/img-omics:0.1.12 (md5sum 21fb20bf430e61ce55430514029e7a83)
#
FROM buildbase as img

RUN \
    cd /opt && \
    wget http://portal.nersc.gov/dna/metagenome/assembly/img-scripts/omics.20200317.tar.gz && \
    tar -zxvf omics.20200317.tar.gz && \
    chmod -R 755 omics && \
    rm -rf /opt/omics/bin  \
    rm omics.20200317.tar.gz

#not reproducible for others to build an image from currently
COPY bin /opt/omics/bin
COPY VERSION /opt/omics    

# MetaGeneMark version was updated for img annotation pipeline 5.1.*


RUN \
    cd /opt && \
    wget http://portal.nersc.gov/dna/metagenome/assembly/gms2_linux_64.v1.14_1.25_lic.tar.gz && \
    tar -zxvf gms2_linux_64.v1.14_1.25_lic.tar.gz && \
    #chmod -R 755 omics && \
    rm gms2_linux_64.v1.14_1.25_lic.tar.gz

# Let's remove some cruft
RUN rm -rf /opt/omics/bin/bu

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

COPY --from=prodigal /usr/local/bin/prodigal /opt/omics/programs/prodigal

COPY --from=trnascan /opt/omics/programs/tRNAscan-SE /opt/omics/programs/tRNAscan-SE
#COPY --from=trnascan /usr/local/lib /opt/omics/programs/tRNAscan-SE/tRNAscan-SE-2.0.8/lib/

COPY --from=hmm /opt/omics/programs/hmmer/ /opt/omics/programs/hmmer
COPY --from=last /opt/omics/programs/last/ /opt/omics/programs/last

COPY --from=last /opt/omics/programs/last /opt/omics/programs/last
COPY --from=img /opt/omics/programs/CRT /opt/omics/programs/CRT
#COPY --from=img /opt/omics/programs/tmhmm-2.0c /opt/omics/programs/tmhmm-2.0c

COPY --from=infernal /opt/omics/programs/infernal /opt/omics/programs/infernal/
COPY --from=img /opt/omics/bin/ /opt/omics/bin/
COPY --from=img /opt/omics/programs/CRT /opt/omics/programs/CRT
COPY --from=img /opt/gms2_linux_64 /opt/omics/programs/gms2_linux_64
COPY --from=img /opt/omics/VERSION /opt/omics/VERSION
RUN \
    mkdir /opt/omics/lib && cd /opt/omics/lib && \
    ln -s ../programs/tRNAscan-SE/tRNAscan-SE-2.0.8/lib/tRNAscan-SE/* . 

#link things to the bin directory

RUN \
    cd /opt/omics/bin &&\ 
    ln -s ../programs/gms2_linux_64/gms2.pl &&\
    ln -s ../programs/gms2_linux_64/gmhmmp2 &&\
    ln -s ../programs/infernal/infernal-1.1.3/bin/cmsearch && \
    ln -s ../programs/tRNAscan-SE/tRNAscan-SE-2.0.8/bin/tRNAscan-SE && \
    ln -s ../programs/last/bin/lastal && \
    ln -s ../programs/CRT/CRT-CLI_v1.8.2.jar CRT-CLI.jar && \
    ln -s ../programs/prodigal &&\
    ln -s ../programs/hmmer/bin/hpc_hmmsearch /opt/omics/bin/hmmsearch 

#make sure tRNAscan can see cmsearch and cmscan

RUN \ 
    cd /opt/omics/programs/tRNAscan-SE/tRNAscan-SE-2.0.8/bin/ &&\
    ln -s /opt/omics/programs/infernal/infernal-1.1.3/bin/cmsearch && \
    ln -s /opt/omics/programs/infernal/infernal-1.1.3/bin/cmscan

#COPY --from=img /opt/omics /opt/omics3/

