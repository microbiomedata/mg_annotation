FROM debian:latest

RUN apt-get update -y 
RUN apt-get install curl gcc make -y

RUN curl --silent --fail -o min.sh -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && bash min.sh -b -p /miniconda3 
RUN /bin/bash -c "source /miniconda3/etc/profile.d/conda.sh && conda activate && conda config --add channels conda-forge && conda config --add channels bioconda  && conda config --add channels anaconda && conda install -y curl git wget jq emacs parallel pyyaml openjdk perl-getopt-long bc procps-ng -y"

#ADD omics.tar.gz /opt
RUN cd /opt && /bin/bash -c "source /miniconda3/etc/profile.d/conda.sh && conda activate && wget http://portal.nersc.gov/dna/metagenome/assembly/img-scripts/omics.20200317.tar.gz && tar -zxvf omics.20200317.tar.gz && chmod -R 755 omics && rm omics.20200317.tar.gz"

RUN cd /opt/omics/bin && /bin/bash -c "source /miniconda3/etc/profile.d/conda.sh && conda activate && curl -s https://api.github.com/repos/broadinstitute/cromwell/releases/latest | jq -r .assets[].browser_download_url | grep -v wom | xargs -i curl --silent -O -L {} && ln -sf cromwell-*.jar ./cromwell.jar"

RUN cd /opt && /bin/bash -c "source /miniconda3/etc/profile.d/conda.sh && conda activate && wget http://eddylab.org/software/hmmer/hmmer.tar.gz && tar -zxvf hmmer.tar.gz && cd hmmer-* && ./configure --prefix /opt/omics && make && make install && cd ../ && rm -r hmmer*"

ENV PERL5LIB '/opt/omics/lib'

# conda shell.posix activate
ENV PS1 '(base) '
ENV  PATH '/miniconda3/bin:/miniconda3/condabin:/opt/omics/bin:/opt/omics/bin/functional_annotation:/opt/omics/bin/qc/post-annotation:/opt/omics/bin/qc/pre-annotation:/opt/omics/bin/structural_annotation:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
ENV  CONDA_PREFIX '/miniconda3'
ENV  CONDA_SHLVL '1'
ENV  CONDA_DEFAULT_ENV 'base'
ENV  CONDA_PROMPT_MODIFIER '(base) '
ENV  CONDA_EXE '/miniconda3/bin/conda'
ENV  _CE_M ''
ENV  _CE_CONDA ''
ENV  CONDA_PYTHON_EXE '/miniconda3/bin/python'
