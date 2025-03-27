# syntax=docker/dockerfile:1
# check=error=true

FROM debian:bullseye AS buildbase
# docker buildx build --progress=plain --no-cache  --platform linux/amd64 -t microbiomedata/img-omics:5.3.0 .

# version variables
ENV IMG_annotation_pipeline_ver=5.3.0
ENV prodigal_ver=2.6.3
ENV trnascan_ver=2.0.12
ENV hmm_ver=3.3.2
ENV hpc_hmm_sha=66a2b4a7a01dab5111163d8372f581de381e8cb1
ENV last_ver=1584
ENV infernal_ver=1.1.4
ENV gms2_ver=1.14_1.25
ENV CRT_ver=1.8.4
ENV cromwell_ver=49
ENV genomad_ver=1.8.1


# Update and clean package lists
RUN apt-get update && \
    apt-get upgrade && \
    apt-get clean

# Install CA certificates
RUN apt-get update && apt-get install -y ca-certificates
RUN update-ca-certificates --fresh

# Install OpenJDK
# for building on arm / mac machine for amd, use `openjdk-11-jdk:amd64`
RUN apt-get update && apt-get install -y openjdk-11-jdk:amd64
# potential fix with openjdk:19-alpine following this comment, if we want
# to use wget instead of ADD (which is better practice) for building on MacOS
# https://forums.docker.com/t/how-to-make-wget-run-in-docker/140555/6

# Install essential packages
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    make \
    wget \
    time \
    autoconf \
    unzip \
    curl \
    libz-dev \
    g++ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*




#
########## Build prodigal
#
FROM buildbase AS prodigal
#4/20/23 Marcel is using a patched version, get from NERSC instead of offical repo
RUN \
    cd /opt  && \
    wget http://portal.nersc.gov/dna/metagenome/assembly/prodigal_${prodigal_ver}_patched/prodigal && \
    chmod 755 prodigal


#
######### Build trnascan
#
FROM buildbase AS trnascan
RUN \
    wget https://github.com/UCSC-LoweLab/tRNAscan-SE/archive/refs/tags/v${trnascan_ver}.tar.gz && \
    tar -xzf v${trnascan_ver}.tar.gz && \
    rm v${trnascan_ver}.tar.gz && \
    cd tRNAscan-SE-${trnascan_ver} && \
    ./configure --prefix=/opt/omics/programs/tRNAscan-SE/tRNAscan-SE-${trnascan_ver}/ && \
    make && \
    make install 


#
########## Build HMMER 3.3.2
#
FROM buildbase AS hmm
RUN \
    cd /opt && \
    wget http://eddylab.org/software/hmmer/hmmer-${hmm_ver}.tar.gz && \
    tar -zxf hmmer-${hmm_ver}.tar.gz && \
    rm hmmer-${hmm_ver}.tar.gz && \
    cd hmmer-${hmm_ver} && \
    ./configure --prefix /opt/omics/programs/hmmer/ && \
    make && \
    make install


# pre 2025: get and extract commit sha a8d641046729328fdda97331d527edb2ce81510a of master branch of modification file, copy into hmmer source code
## for hmmer version 3.3.2 the hpc_hmmsearch should use the code in master branch
# 2025: master branch sha 66a2b4a7a01dab5111163d8372f581de381e8cb1 for oct 5, 2022 version
# ENV hpc_hmm_sha=66a2b4a7a01dab5111163d8372f581de381e8cb1
RUN \
    wget https://github.com/Larofeticus/hpc_hmmsearch/archive/${hpc_hmm_sha}.zip && \
    unzip ${hpc_hmm_sha}.zip && \
    rm ${hpc_hmm_sha}.zip && \
    cp /hpc_hmmsearch-*/hpc_hmmsearch.c /opt/hmmer-${hmm_ver}/src && \
    cd /opt/hmmer-${hmm_ver}/src && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -fopenmp -fPIC -msse2 -DHAVE_CONFIG_H -I../easel -I../libdivsufsort -I../easel -I. -I. -o hpc_hmmsearch.o -c hpc_hmmsearch.c && \
    gcc -std=gnu99 -O3 -fomit-frame-pointer -fstrict-aliasing -march=core2 -fopenmp -fPIC -msse2 -DHAVE_CONFIG_H -L../easel -L./impl_sse -L../libdivsufsort -L. -o hpc_hmmsearch hpc_hmmsearch.o -lhmmer -leasel -ldivsufsort -lm && \
    cp hpc_hmmsearch /opt/omics/programs/hmmer/bin/ && \
    /opt/omics/programs/hmmer/bin/hpc_hmmsearch -h

#
########## Build last 1584
#
FROM buildbase AS last
RUN \
    wget https://gitlab.com/mcfrith/last/-/archive/1584/last-${last_ver}.tar.gz && \
    tar -zxf last-${last_ver}.tar.gz && \
    rm last-${last_ver}.tar.gz && \
    cd last-${last_ver} && \
    make && \
    make prefix=/opt/omics/programs/last install


#
########## Build infernal 1.1.4
#
FROM buildbase AS infernal

RUN \
    wget http://eddylab.org/infernal/infernal-${infernal_ver}.tar.gz  && \
    tar -zxf infernal-${infernal_ver}.tar.gz && \
    rm infernal-${infernal_ver}.tar.gz && \
    cd infernal-${infernal_ver} && \
    ./configure --prefix=/opt/omics/programs/infernal/infernal-${infernal_ver} && \
    make && \
    make install 


#
########## IMG scripts and tools v 5.1.14, repo is public 4/2023. Add split.py from bfoster1/img-omics:0.1.12 (md5sum 21fb20bf430e61ce55430514029e7a83)
#
FROM buildbase AS img

RUN \
    cd /opt && \
    wget https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline/-/archive/${IMG_annotation_pipeline_ver    }/img-annotation-pipeline-${IMG_annotation_pipeline_ver    }.tar.gz && \
    tar -xzf img-annotation-pipeline-${IMG_annotation_pipeline_ver    }.tar.gz && \
    rm img-annotation-pipeline-${IMG_annotation_pipeline_ver    }.tar.gz

RUN \
    cd /opt && \
    wget https://code.jgi.doe.gov/official-jgi-workflows/jgi-wdl-pipelines/img-omics/-/raw/83c5483f0fd8afc43a2956ed065bffc08d8574da/bin/split.py && \
    chmod 755 split.py

########## MetaGeneMark version was updated for img annotation pipeline 5.1.*
RUN \
    cd /opt && \
    wget http://portal.nersc.gov/dna/metagenome/assembly/gms2_linux_64.v${gms2_ver}_lic.tar.gz && \
    tar -zxf gms2_linux_64.v${gms2_ver}_lic.tar.gz && \
    rm gms2_linux_64.v${gms2_ver}_lic.tar.gz

########## get CRT version 1.8.4
RUN \
    wget https://code.jgi.doe.gov/img/img-pipelines/crt-cli-imgap-version/-/archive/${CRT_ver}/crt-cli-imgap-version-${CRT_ver}.tar.gz && \
    tar -xzf crt-cli-imgap-version-${CRT_ver}.tar.gz && \
    rm crt-cli-imgap-version-${CRT_ver}.tar.gz && \
    cd crt-cli-imgap-version-${CRT_ver}/src && \
    javac *.java && \
    jar cfe CRT-CLI.jar crt *.class && \
    cp CRT-CLI.jar /opt/.


#
########### Build the final image
#
FROM buildbase AS conda

########## Install Miniconda

RUN \
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \ 
    bash ./Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda3

ENV PATH=/miniconda3/bin:/miniconda3/condabin:$PATH

RUN \
    conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda config --add channels anaconda
RUN conda install -y conda-forge::ca-certificates
RUN conda install -y curl git wget jq parallel pyyaml openjdk perl-getopt-long bc procps-ng

RUN conda clean -y -a

#
########## Install Cromwell v49
#
FROM buildbase AS cromwell
RUN \
    mkdir -p /opt/omics/bin && \
    cd /opt/omics/bin && \
    wget -q https://github.com/broadinstitute/cromwell/releases/download/${cromwell_ver}/cromwell-${cromwell_ver}.jar && \
    ln -sf cromwell-${cromwell_ver}.jar cromwell.jar

#
##########
#
FROM buildbase

COPY --from=conda /miniconda3 /miniconda3

# conda shell.posix activate
ENV  PATH='/miniconda3/bin:/miniconda3/condabin:/opt/omics/bin:/opt/omics/bin/functional_annotation:/opt/omics/bin/qc/post-annotation:/opt/omics/bin/qc/pre-annotation:/opt/omics/bin/structural_annotation:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
ENV  CONDA_PREFIX='/miniconda3'
ENV  CONDA_EXE='/miniconda3/bin/conda'
ENV  _CE_M=''
ENV  _CE_CONDA=''
ENV  CONDA_PYTHON_EXE='/miniconda3/bin/python'

# move everything to /opt
COPY --from=cromwell /opt/omics/bin/ /opt/omics/bin/
COPY --from=prodigal /opt/prodigal /opt/omics/programs/prodigal
COPY --from=trnascan /opt/omics/programs/tRNAscan-SE /opt/omics/programs/tRNAscan-SE
COPY --from=hmm /opt/omics/programs/hmmer/ /opt/omics/programs/hmmer
COPY --from=last /opt/omics/programs/last/ /opt/omics/programs/last
COPY --from=infernal /opt/omics/programs/infernal/ /opt/omics/programs/infernal/
COPY --from=img /opt/img-annotation-pipeline-${IMG_annotation_pipeline_ver    }/bin/ /opt/omics/bin/
COPY --from=img /opt/split.py /opt/omics/bin/split.py
COPY --from=img /opt/gms2_linux_64 /opt/omics/programs/gms2_linux_64
COPY --from=img /opt/CRT-CLI.jar /opt/omics/programs/CRT/CRT-CLI.jar
COPY --from=img /opt/img-annotation-pipeline/VERSION /opt/omics/VERSION
RUN \
    mkdir /opt/omics/lib && \
    cd /opt/omics/lib && \
    ln -s ../programs/tRNAscan-SE/lib/tRNAscan-SE/* . 

#link things to the bin directory
RUN \
    cd /opt/omics/bin && \ 
    ln -s ../programs/gms2_linux_64/gms2.pl && \
    ln -s ../programs/gms2_linux_64/gmhmmp2 && \
    ln -s ../programs/infernal/infernal-${infernal_ver}/bin/cmsearch && \
    ln -s ../programs/tRNAscan-SE/bin/tRNAscan-SE && \
    ln -s ../programs/last/bin/lastal && \
    ln -s ../programs/CRT/CRT-CLI.jar CRT-CLI.jar && \
    ln -s ../programs/prodigal && \
    ln -s ../programs/hmmer/bin/hpc_hmmsearch /opt/omics/bin/hmmsearch 

#make sure tRNAscan can see cmsearch and cmscan
RUN \ 
    cd /opt/omics/programs/tRNAscan-SE/bin/ && \
    ln -s /opt/omics/programs/infernal/bin/cmsearch && \
    ln -s /opt/omics/programs/infernal/bin/cmscan

# copy from existing genomad container
COPY --from=microbiomedata/img-genomad:1.0.0_g1.8.1 /opt/conda/bin/seqkit /opt/conda/bin/seqkit
COPY --from=microbiomedata/img-genomad:1.0.0_g1.8.1 /opt/conda/bin/genomad /opt/conda/bin/genomad
COPY --from=microbiomedata/img-genomad:1.0.0_g1.8.1 /usr/local/bin/_entrypoint.sh /usr/local/bin/_entrypoint.sh
COPY --from=microbiomedata/img-genomad:1.0.0_g1.8.1 /usr/local/bin/genomad.sh /usr/local/bin/genomad.sh

