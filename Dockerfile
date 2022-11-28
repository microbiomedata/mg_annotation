FROM debian as buildbase

RUN apt-get -y update && apt-get -y install git gcc make wget

RUN apt-get -y install libz-dev
#
# Build prodigal
#
FROM buildbase as prodigal

RUN git clone https://github.com/hyattpd/Prodigal

RUN cd Prodigal && git checkout v2.6.3 && make

RUN cd Prodigal && make install

#
# Build trnascan 2.0.06
#
FROM buildbase as trnascan

RUN apt-get -y install autoconf

RUN wget http://trna.ucsc.edu/software/trnascan-se-2.0.6.tar.gz

RUN \
    tar xzvf trnascan-se-2.0.6.tar.gz && \
    cd tRNAscan-SE-2.0 && \
    ./configure --prefix=/opt/omics/programs/tRNAscan-SE/tRNAscan-SE/ && \
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

# get and extract master branch of modification file, copy into hmmer source code
RUN \
    wget -v https://github.com/Larofeticus/hpc_hmmsearch/tarball/master && \
    tar -xvf master && \
    cp /Larofeticus-hpc_hmmsearch-*/hpc_hmmsearch.c /opt/hmmer-3.1b2/src && \
    cd /opt/hmmer-$V/src && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -pthread -fPIC -msse2 -DHAVE_CONFIG_H -I../easel -I../libdivsufsort -I../easel -I. -I. -o hpc_hmmsearch.o -c hpc_hmmsearch.c && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -pthread -fPIC -msse2 -DHAVE_CONFIG_H -L../easel -L./impl_sse -L../libdivsufsort -L. -o hpc_hmmsearch hpc_hmmsearch.o -lhmmer -leasel -ldivsufsort -lm  && \
   cp hpc_hmmsearch /opt/omics/programs/hmmer/bin/ && \
   /opt/omics/programs/hmmer/bin/hpc_hmmsearch -h

# Build last 983
#
FROM buildbase as last

RUN apt-get -y install unzip g++

RUN \
    wget last.cbrc.jp/last-983.zip &&  \
    unzip last-983.zip

RUN \
    cd last-983 && \
    make && \
    make prefix=/opt/omics/programs/last install

# Build infernal 1.1.2
#
FROM buildbase as infernal

RUN \
    wget http://eddylab.org/infernal/infernal-1.1.2.tar.gz && \
    tar xzf infernal-1.1.2.tar.gz

RUN \
    cd infernal-1.1.2 && \
    ./configure --prefix=/opt/omics/programs/infernal/infernal-1.1.2 && \
    make && make install

#
# IMG scripts and tools
#
FROM buildbase as img

RUN \
    cd /opt && \
    wget http://portal.nersc.gov/dna/metagenome/assembly/img-scripts/omics.20200317.tar.gz && \
    tar -zxvf omics.20200317.tar.gz && \
    chmod -R 755 omics && \
    rm omics.20200317.tar.gz

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

COPY --from=prodigal /usr/local/bin/prodigal /opt/omics/programs/prodigal/prodigal_v2.6.3

COPY --from=trnascan /opt/omics/programs/tRNAscan-SE /opt/omics/programs/tRNAscan-SE/
#COPY --from=trnascan /usr/local/lib /opt/omics/programs/tRNAscan-SE/tRNAscan-SE/lib/

COPY --from=hmm /opt/omics /opt/omics/

COPY --from=last /opt/omics/programs/last /opt/omics/programs/last/last-983

COPY --from=infernal /opt/omics/programs/infernal /opt/omics/programs/infernal/

COPY --from=img /opt/omics/bin/ /opt/omics/bin/
COPY --from=img /opt/omics/programs/CRT /opt/omics/programs/CRT
COPY --from=img /opt/omics/programs/GeneMark /opt/omics/programs/GeneMark
COPY --from=img /opt/omics/programs/tmhmm-2.0c /opt/omics/programs/tmhmm-2.0c

RUN \
    mkdir /opt/omics/lib && cd /opt/omics/lib && \
    ln -s ../programs/tRNAscan-SE/tRNAscan-SE/lib/tRNAscan-SE/* .

RUN \
    cd /opt/omics/programs/tRNAscan-SE/tRNAscan-SE/bin/ && \
    sed -i  's|infernal_dir: {bin_dir}|infernal_dir: /opt/omics/programs/infernal/infernal-1.1.2/bin/|' tRNAscan-SE.conf

#COPY --from=img /opt/omics /opt/omics3/

