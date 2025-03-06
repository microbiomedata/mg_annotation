FROM debian:bullseye AS buildbase

# Update and clean package lists
RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y clean

# Install CA certificates
RUN apt-get -y update && apt-get -y install ca-certificates
RUN update-ca-certificates --fresh

# Install OpenJDK
# for building on arm / mac machine for amd, use `openjdk-11-jdk:amd64`
RUN apt-get -y update && apt-get install -y openjdk-11-jdk
# potential fix with openjdk:19-alpine following this comment, if we want
# to use wget instead of ADD (which is better practice) for building on MacOS
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

# ADD --chmod=755 http://portal.nersc.gov/dna/metagenome/assembly/prodigal_2.6.3_patched/prodigal /opt/
RUN \
    cd /opt && \
    wget http://portal.nersc.gov/dna/metagenome/assembly/prodigal_2.6.3_patched/prodigal && \
    chmod 755 prodigal


######### Build trnascan
#
FROM buildbase AS trnascan
ENV trnascan_ver=2.0.12
# ADD https://github.com/UCSC-LoweLab/tRNAscan-SE/archive/refs/tags/v${trnascan_ver}.tar.gz .

RUN git clone --depth 1 --branch v${trnascan_ver} https://github.com/UCSC-LoweLab/tRNAscan-SE
# RUN wget https://github.com/UCSC-LoweLab/tRNAscan-SE/archive/refs/tags/v${trnascan_ver}.tar.gz

RUN \
    # tar -xzf v${trnascan_ver}.tar.gz && \
    # cd tRNAscan-SE-${trnascan_ver} && \
    cd tRNAscan-SE && \
    # ./configure --prefix=/opt/omics/programs/tRNAscan-SE/ && \
    make && \
    make prefix=/opt/omics/programs/tRNAscan-SE/ install

#
########## Build HMMER 3.3.2
#
FROM buildbase AS hmm

ENV hmm_ver=3.3.2
# ADD http://eddylab.org/software/hmmer/hmmer-${hmm_ver}.tar.gz /opt/
# RUN \
#     cd /opt && \
#     # wget http://eddylab.org/software/hmmer/hmmer-${hmm_ver}.tar.gz && \
#     # tar -zxf hmmer-${hmm_ver}.tar.gz && \
#     cd hmmer-${hmm_ver} && \
#     # ./configure --prefix /opt/omics/programs/hmmer/ && \
#     make && \
#     make prefix=/opt/omics/programs/hmmer/ install

RUN \
    cd /opt && \
    git clone --depth 1 --branch hmmer-${hmm_ver} https://github.com/EddyRivasLab/hmmer
RUN \
    cd hmmer && \
    make && \
    make prefix=/opt/omics/programs/hmmer/ install


# get and extract commit sha a8d641046729328fdda97331d527edb2ce81510a  of master branch of modification file, copy into hmmer source code
## for hmmer version 3.3.2 the hpc_hmmsearch should use the code in master branch
# master branch sha 66a2b4a7a01dab5111163d8372f581de381e8cb1 for oct 5, 2022
ENV hpc_hmm_sha=66a2b4a7a01dab5111163d8372f581de381e8cb1
RUN \
    wget https://github.com/Larofeticus/hpc_hmmsearch/archive/${hpc_hmm_sha}.zip && \
    unzip ${hpc_hmm_sha}.zip && \
    cp /hpc_hmmsearch-*/hpc_hmmsearch.c /opt/hmmer/src && \
    cd /opt/hmmer/src && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -fopenmp -fPIC -msse2 -DHAVE_CONFIG_H -I../easel -I../libdivsufsort -I../easel -I. -I. -o hpc_hmmsearch.o -c hpc_hmmsearch.c && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -fopenmp -fPIC -msse2 -DHAVE_CONFIG_H -L../easel -L./impl_sse -L../libdivsufsort -L. -o hpc_hmmsearch hpc_hmmsearch.o -lhmmer -leasel -ldivsufsort -lm  && \
    cp hpc_hmmsearch /opt/omics/programs/hmmer/bin/ && \
    /opt/omics/programs/hmmer/bin/hpc_hmmsearch -h
   
########## Build last 1584
#
FROM buildbase AS last
ENV last_ver=1584

# ADD https://gitlab.com/mcfrith/last/-/archive/${last_ver}/last-${last_ver}.tar.gz .

# RUN \
#     tar -zxf last-${last_ver}.tar.gz && \
#     cd last-${last_ver} && \
#     make && \
#     make prefix=/opt/omics/programs/last install

RUN git clone --depth 1 --branch ${last_ver} https://gitlab.com/mcfrith/last
RUN \
    cd last && \
    make && \
    make prefix=/opt/omics/programs/last install

########## Build infernal 1.1.4
#
FROM buildbase AS infernal

ENV infernal_ver=1.1.4

# RUN \
#     wget http://eddylab.org/infernal/infernal-${infernal_ver}.tar.gz && \
#     tar -zxf infernal-${infernal_ver}.tar.gz

RUN git clone --depth 1 --branch infernal-${infernal_ver} https://github.com/EddyRivasLab/infernal

RUN \
    cd infernal && \
    # ./configure --prefix=/opt/omics/programs/infernal/ && \
    make && \
    make prefix=/opt/omics/programs/infernal/ install

#
########## IMG scripts and tools v 5.1.14, repo is public 4/2023. Add split.py from bfoster1/img-omics:0.1.12 (md5sum 21fb20bf430e61ce55430514029e7a83)
#
FROM buildbase AS img

ENV IMG_annotation_pipeline_ver=5.3.0

RUN \
    cd /opt && \
    git clone --depth 1 --branch ${IMG_annotation_pipeline_ver} https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline

RUN \
    cd /opt && \
    curl https://code.jgi.doe.gov/official-jgi-workflows/jgi-wdl-pipelines/img-omics/-/raw/83c5483f0fd8afc43a2956ed065bffc08d8574da/bin/split.py > split.py && \
    chmod 755 split.py

# ADD https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline/-/archive/${IMG_annotation_pipeline_ver}/img-annotation-pipeline-${IMG_annotation_pipeline_ver}.tar.gz /opt/
# RUN \
#     cd /opt && \
#     tar -zxvf img-annotation-pipeline-${IMG_annotation_pipeline_ver}.tar.gz 

# ADD --chmod=755 https://code.jgi.doe.gov/official-jgi-workflows/jgi-wdl-pipelines/img-omics/-/raw/83c5483f0fd8afc43a2956ed065bffc08d8574da/bin/split.py /opt/

#
########## MetaGeneMark version was updated for img annotation pipeline 5.1.*

# ADD http://portal.nersc.gov/dna/metagenome/assembly/gms2_linux_64.v1.14_1.25_lic.tar.gz /opt/
RUN \
    cd /opt && \
    wget http://portal.nersc.gov/dna/metagenome/assembly/gms2_linux_64.v1.14_1.25_lic.tar.gz && \
    tar -zxvf gms2_linux_64.v1.14_1.25_lic.tar.gz && \
    rm gms2_linux_64.v1.14_1.25_lic.tar.gz



#
########## get CRT version 1.8.4
# ADD https://code.jgi.doe.gov/img/img-pipelines/crt-cli-imgap-version/-/archive/main/crt-cli-imgap-version-main.zip .
# RUN \
#     # wget https://code.jgi.doe.gov/img/img-pipelines/crt-cli-imgap-version/-/archive/main/crt-cli-imgap-version-main.zip && \
#     unzip -q crt-cli-imgap-version-main.zip && \
#     cd crt-cli-imgap-version-main/src && \
#     javac *.java && \
#     jar cfe CRT-CLI.jar crt *.class && \
#     cp CRT-CLI.jar /opt/.

ENV CRT_ver=1.8.4

RUN git clone --depth 1 --branch ${CRT_ver} https://code.jgi.doe.gov/img/img-pipelines/crt-cli-imgap-version
RUN \
    cd crt-cli-imgap-version/src && \
    javac *.java && \
    jar cfe CRT-CLI.jar crt *.class && \
    cp CRT-CLI.jar /opt/.

#
# Build the final image
#
FROM buildbase AS conda

########## Install Miniconda
#
# ADD https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh .
RUN \
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \ 
    bash ./Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda3

ENV PATH=/miniconda3/bin:/miniconda3/condabin:$PATH

RUN conda config --add channels conda-forge && conda config --add channels bioconda  && conda config --add channels anaconda
RUN conda install -y conda-forge::ca-certificates
RUN conda install -y curl git wget jq parallel pyyaml openjdk perl-getopt-long bc procps-ng

RUN conda clean -y -a

#
########## Install Cromwell v49
#
FROM buildbase AS cromwell
ENV cromwell_ver=49

# RUN mkdir -p /opt/omics/bin
# ADD https://github.com/broadinstitute/cromwell/releases/download/${cromwell_ver}/cromwell-${cromwell_ver}.jar /opt/omics/bin/
# RUN ln -sf cromwell-${cromwell_ver}.jar cromwell.jar
RUN \
    mkdir -p /opt/omics/bin && \
    cd /opt/omics/bin && \
    wget -q https://github.com/broadinstitute/cromwell/releases/download/${cromwell_ver}/cromwell-${cromwell_ver}.jar && \
    ln -sf cromwell-${cromwell_ver}.jar cromwell.jar

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

COPY --from=cromwell /opt/omics/bin/ /opt/omics/bin/

COPY --from=prodigal /opt/prodigal /opt/omics/programs/prodigal

COPY --from=trnascan /opt/omics/programs/tRNAscan-SE /opt/omics/programs/tRNAscan-SE
#COPY --from=trnascan /usr/local/lib /opt/omics/programs/tRNAscan-SE/tRNAscan-SE-${trnascan_ver}/lib/

COPY --from=hmm /opt/omics/programs/hmmer/ /opt/omics/programs/hmmer
COPY --from=last /opt/omics/programs/last/ /opt/omics/programs/last

COPY --from=last /opt/omics/programs/last /opt/omics/programs/last
COPY --from=img /opt/CRT-CLI.jar /opt/omics/programs/CRT/CRT-CLI.jar
COPY --from=img /opt/split.py /opt/omics/bin/split.py

COPY --from=infernal /opt/omics/programs/infernal /opt/omics/programs/infernal/
COPY --from=img /opt/img-annotation-pipeline/bin/ /opt/omics/bin/
COPY --from=img /opt/gms2_linux_64 /opt/omics/programs/gms2_linux_64
COPY --from=img /opt/img-annotation-pipeline/VERSION /opt/omics/VERSION
RUN \
    mkdir /opt/omics/lib && cd /opt/omics/lib && \
    ln -s ../programs/tRNAscan-SE/lib/tRNAscan-SE/* . 

#link things to the bin directory

RUN \
    cd /opt/omics/bin &&\ 
    ln -s ../programs/gms2_linux_64/gms2.pl &&\
    ln -s ../programs/gms2_linux_64/gmhmmp2 &&\
    ln -s ../programs/infernal/bin/cmsearch && \
    ln -s ../programs/tRNAscan-SE/bin/tRNAscan-SE && \
    ln -s ../programs/last/bin/lastal && \
    ln -s ../programs/CRT/CRT-CLI.jar CRT-CLI.jar && \
    ln -s ../programs/prodigal &&\
    ln -s ../programs/hmmer/bin/hpc_hmmsearch /opt/omics/bin/hmmsearch 

#make sure tRNAscan can see cmsearch and cmscan

RUN \ 
    cd /opt/omics/programs/tRNAscan-SE/bin/ &&\
    ln -s /opt/omics/programs/infernal/bin/cmsearch && \
    ln -s /opt/omics/programs/infernal/bin/cmscan

