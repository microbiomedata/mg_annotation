FROM debian:bullseye AS buildbase

# Update and clean package lists
RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y clean

# Install CA certificates
RUN apt-get -y update && apt-get -y install ca-certificates
RUN update-ca-certificates --fresh

# Install OpenJDK
# original: RUN apt-get -y install openjdk-11-jdk
# for building on arm / mac machine for amd
# RUN apt-get -y update && apt-get install -y openjdk-11-jdk:amd64
RUN apt-get -y update && apt-get install -y 
# potential fix with openjdk:19-alpine following this comment, if we want
# to use wget instead of ADD (which is better practice)
# https://forums.docker.com/t/how-to-make-wget-run-in-docker/140555/6

# Install essential packages
RUN apt-get -y install \
    git \
    gcc \
    make \
    wget \
    time \
    autoconf \
    unzip \
    curl \
    libz-dev \
    g++

#
########## Build prodigal
#
FROM buildbase AS prodigal
#4/20/23 Marcel is using a patched version, get from NERSC instead of offical repo

ADD --chmod=755 http://portal.nersc.gov/dna/metagenome/assembly/prodigal_2.6.3_patched/prodigal /opt/
# RUN \
#     cd /opt && \
#     wget http://portal.nersc.gov/dna/metagenome/assembly/prodigal_2.6.3_patched/prodigal && \
#     chmod 755 prodigal

#RUN git clone --branch v2.6.3 https://github.com/hyattpd/Prodigal
#RUN cd Prodigal && make install


######### Build trnascan
#
FROM buildbase AS trnascan
ADD https://github.com/UCSC-LoweLab/tRNAscan-SE/archive/refs/tags/v2.0.12.tar.gz .

# RUN wget https://github.com/UCSC-LoweLab/tRNAscan-SE/archive/refs/tags/v2.0.12.tar.gz

RUN \
    tar -xzf v2.0.12.tar.gz && \
    cd tRNAscan-SE-2.0.12 && \
    ./configure --prefix=/opt/omics/programs/tRNAscan-SE/tRNAscan-SE-2.0.12/ && \
    make && make install

#
########## Build HMMER 3.3.2
#
FROM buildbase AS hmm

ENV V=3.3.2
ADD http://eddylab.org/software/hmmer/hmmer-$V.tar.gz /opt/
RUN \
    cd /opt && \
    # wget http://eddylab.org/software/hmmer/hmmer-$V.tar.gz && \
    tar -zxf hmmer-$V.tar.gz && \
    cd hmmer-$V && ./configure --prefix /opt/omics/programs/hmmer/ && \
    make && make install

# get and extract commit sha a8d641046729328fdda97331d527edb2ce81510a  of master branch of modification file, copy into hmmer source code
RUN \
    wget https://github.com/Larofeticus/hpc_hmmsearch/archive/a8d641046729328fdda97331d527edb2ce81510a.zip && \
    unzip a8d641046729328fdda97331d527edb2ce81510a.zip && \
    cp /hpc_hmmsearch-*/hpc_hmmsearch.c /opt/hmmer-$V/src && \
    cd /opt/hmmer-$V/src && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -fopenmp -fPIC -msse2 -DHAVE_CONFIG_H -I../easel -I../libdivsufsort -I../easel -I. -I. -o hpc_hmmsearch.o -c hpc_hmmsearch.c && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -fopenmp -fPIC -msse2 -DHAVE_CONFIG_H -L../easel -L./impl_sse -L../libdivsufsort -L. -o hpc_hmmsearch hpc_hmmsearch.o -lhmmer -leasel -ldivsufsort -lm  && \
   cp hpc_hmmsearch /opt/omics/programs/hmmer/bin/ && \
   /opt/omics/programs/hmmer/bin/hpc_hmmsearch -h
   
########## Build last 1584
#
FROM buildbase AS last

# RUN \
#     wget https://gitlab.com/mcfrith/last/-/archive/1584/last-1584.tar.gz && \
#     tar -zxf last-1584.tar.gz 
ADD https://gitlab.com/mcfrith/last/-/archive/1584/last-1584.tar.gz .
# RUN curl -L https://gitlab.com/mcfrith/last/-/archive/1584/last-1584.tar.gz
# RUN tar -zxf last-1584.tar.gz
RUN \
    tar -zxf last-1584.tar.gz && \
    cd last-1584 && \
    make && \
    make prefix=/opt/omics/programs/last install

# RUN \
#     git clone --depth 1 --branch 1584 https://gitlab.com/mcfrith/last && \
#     cd last && \
#     make && \
#     make prefix=/opt/omics/programs/last install

########## Build infernal 1.1.4
#
FROM buildbase AS infernal

ENV infernal_ver=1.1.4

RUN \
    wget http://eddylab.org/infernal/infernal-${infernal_ver}.tar.gz && \
    tar -zxf infernal-${infernal_ver}.tar.gz

RUN \
    cd infernal-${infernal_ver} && \
    ./configure --prefix=/opt/omics/programs/infernal/infernal-${infernal_ver} && \
    make && make install

#
########## IMG scripts and tools v 5.1.14, repo is public 4/2023. Add split.py from bfoster1/img-omics:0.1.12 (md5sum 21fb20bf430e61ce55430514029e7a83)
#
FROM buildbase AS img

# RUN \
#     cd /opt && \
#     git clone --depth 1 --branch 5.3 https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline

ENV IMG_annoation_pipeline_ver=5.3.0

ADD https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline/-/archive/$IMG_annoation_pipeline_ver/img-annotation-pipeline-${IMG_annoation_pipeline_ver}.tar.gz /opt/

RUN \
    cd /opt && \
    tar -zxvf img-annotation-pipeline-${IMG_annoation_pipeline_ver}.tar.gz 
    # && \
    # mkdir img-annotation-pipeline && \
    # mv img-annotation-pipeline-${IMG_annoation_pipeline_ver}/* img-annotation-pipeline/ && \
    # ls img-annotation-pipeline

ADD --chmod=755 https://code.jgi.doe.gov/official-jgi-workflows/jgi-wdl-pipelines/img-omics/-/raw/83c5483f0fd8afc43a2956ed065bffc08d8574da/bin/split.py /opt/
# RUN \
#    cd /opt && \
#    curl https://code.jgi.doe.gov/official-jgi-workflows/jgi-wdl-pipelines/img-omics/-/raw/83c5483f0fd8afc43a2956ed065bffc08d8574da/bin/split.py > split.py && \
#    chmod 755 split.py

########## MetaGeneMark version was updated for img annotation pipeline 5.1.*

ADD http://portal.nersc.gov/dna/metagenome/assembly/gms2_linux_64.v1.14_1.25_lic.tar.gz /opt/
RUN \
    cd /opt && \
    tar -zxvf gms2_linux_64.v1.14_1.25_lic.tar.gz && \
    rm gms2_linux_64.v1.14_1.25_lic.tar.gz

# RUN \
#     cd /opt && \
#     wget http://portal.nersc.gov/dna/metagenome/assembly/gms2_linux_64.v1.14_1.25_lic.tar.gz && \
#     tar -zxvf gms2_linux_64.v1.14_1.25_lic.tar.gz && \
#     #chmod -R 755 omics && \
#     rm gms2_linux_64.v1.14_1.25_lic.tar.gz

#
########## get CRT version 1.8.4
ADD https://code.jgi.doe.gov/img/img-pipelines/crt-cli-imgap-version/-/archive/main/crt-cli-imgap-version-main.zip .
RUN \
    # wget https://code.jgi.doe.gov/img/img-pipelines/crt-cli-imgap-version/-/archive/main/crt-cli-imgap-version-main.zip && \
    unzip -q crt-cli-imgap-version-main.zip && \
    cd crt-cli-imgap-version-main/src && \
    javac *.java && \
    jar cfe CRT-CLI.jar crt *.class && \
    cp CRT-CLI.jar /opt/.



#
# Build the final image
#
FROM buildbase AS conda

########## Install Miniconda
#
# RUN \
    # replaced by ADD
    # wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \ 

ADD https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh .
RUN bash ./Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda3

ENV PATH=/miniconda3/bin:/miniconda3/condabin:$PATH

RUN conda config --add channels conda-forge && conda config --add channels bioconda  && conda config --add channels anaconda
RUN conda install -y conda-forge::ca-certificates
RUN conda install -y curl git wget jq parallel pyyaml openjdk perl-getopt-long bc procps-ng

RUN conda clean -y -a

#
########## Install Cromwell v49
#
FROM buildbase AS cromwell

RUN mkdir -p /opt/omics/bin
ADD https://github.com/broadinstitute/cromwell/releases/download/49/cromwell-49.jar /opt/omics/bin/
RUN ln -sf cromwell-49.jar cromwell.jar
# RUN \
#     mkdir -p /opt/omics/bin && \
#     cd /opt/omics/bin && \
#     wget -q https://github.com/broadinstitute/cromwell/releases/download/49/cromwell-49.jar && \
#     ln -sf cromwell-49.jar cromwell.jar

FROM buildbase

ENV PERL5LIB='/opt/omics/lib'
COPY --from=conda /miniconda3 /miniconda3

# conda shell.posix activate
ENV  PATH='/miniconda3/bin:/miniconda3/condabin:/opt/omics/bin:/opt/omics/bin/functional_annotation:/opt/omics/bin/qc/post-annotation:/opt/omics/bin/qc/pre-annotation:/opt/omics/bin/structural_annotation:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
ENV  CONDA_PREFIX='/miniconda3'
ENV  CONDA_EXE='/miniconda3/bin/conda'
ENV  _CE_M=''
ENV  _CE_CONDA=''
ENV  CONDA_PYTHON_EXE='/miniconda3/bin/python'
ENV  IMG_annoation_pipeline_ver=5.3.0
ENV  infernal_ver=1.1.4

COPY --from=cromwell /opt/omics/bin/ /opt/omics/bin/

COPY --from=prodigal /opt/prodigal /opt/omics/programs/prodigal

COPY --from=trnascan /opt/omics/programs/tRNAscan-SE /opt/omics/programs/tRNAscan-SE
#COPY --from=trnascan /usr/local/lib /opt/omics/programs/tRNAscan-SE/tRNAscan-SE-2.0.12/lib/

COPY --from=hmm /opt/omics/programs/hmmer/ /opt/omics/programs/hmmer
COPY --from=last /opt/omics/programs/last/ /opt/omics/programs/last

COPY --from=last /opt/omics/programs/last /opt/omics/programs/last
COPY --from=img /opt/CRT-CLI.jar /opt/omics/programs/CRT/CRT-CLI.jar
COPY --from=img /opt/split.py /opt/omics/bin/split.py

COPY --from=infernal /opt/omics/programs/infernal /opt/omics/programs/infernal/
COPY --from=img /opt/img-annotation-pipeline-${IMG_annoation_pipeline_ver}/bin/ /opt/omics/bin/
COPY --from=img /opt/gms2_linux_64 /opt/omics/programs/gms2_linux_64
COPY --from=img /opt/img-annotation-pipeline-${IMG_annoation_pipeline_ver}/VERSION /opt/omics/VERSION
RUN \
    mkdir /opt/omics/lib && cd /opt/omics/lib && \
    ln -s ../programs/tRNAscan-SE/tRNAscan-SE-2.0.12/lib/tRNAscan-SE/* . 

#link things to the bin directory

RUN \
    cd /opt/omics/bin &&\ 
    ln -s ../programs/gms2_linux_64/gms2.pl &&\
    ln -s ../programs/gms2_linux_64/gmhmmp2 &&\
    ln -s ../programs/infernal/infernal-${infernal_ver}/bin/cmsearch && \
    ln -s ../programs/tRNAscan-SE/tRNAscan-SE-2.0.12/bin/tRNAscan-SE && \
    ln -s ../programs/last/bin/lastal && \
    ln -s ../programs/CRT/CRT-CLI.jar CRT-CLI.jar && \
    ln -s ../programs/prodigal &&\
    ln -s ../programs/hmmer/bin/hpc_hmmsearch /opt/omics/bin/hmmsearch 

#make sure tRNAscan can see cmsearch and cmscan

RUN \ 
    cd /opt/omics/programs/tRNAscan-SE/tRNAscan-SE-2.0.12/bin/ &&\
    ln -s /opt/omics/programs/infernal/infernal-${infernal_ver}/bin/cmsearch && \
    ln -s /opt/omics/programs/infernal/infernal-${infernal_ver}/bin/cmscan

#COPY --from=img /opt/omics /opt/omics3/
