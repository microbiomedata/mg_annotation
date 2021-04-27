FROM debian as buildbase

RUN apt-get -y update && apt-get -y install git gcc make wget

RUN apt-get -y install libz-dev

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
# Build trnascan 2.0.07
#
FROM buildbase as trnascan

RUN apt-get -y install autoconf

RUN wget http://trna.ucsc.edu/software/trnascan-se-2.0.7.tar.gz

RUN \
    tar xzvf trnascan-se-2.0.7.tar.gz && \
    cd tRNAscan-SE-2.0 && \
    ./configure --prefix=/opt/omics/programs/tRNAscan-SE/tRNAscan-SE/ && \
    make && make install

ADD trnascan.patch /tmp/trnascan.patch
RUN \
    cd /opt/omics/programs/tRNAscan-SE/tRNAscan-SE/bin && \
    cat /tmp/trnascan.patch | patch -p0

FROM scanon/imtools:v0.0

ENV PERL5LIB '/opt/omics/lib'

COPY --from=trnascan /opt/omics/programs/tRNAscan-SE /opt/omics/programs/tRNAscan-SE/

COPY --from=infernal /opt/omics/programs/infernal /opt/omics/programs/infernal/

RUN \
    mkdir /opt/omics/lib && cd /opt/omics/lib && \
    ln -s ../programs/tRNAscan-SE/tRNAscan-SE/lib/tRNAscan-SE/* . && \
    ln -s /opt/omics/programs/tRNAscan-SE/tRNAscan-SE/bin/tRNAscan-SE /opt/omics/bin/tRNAscan-SE

RUN \
    cd /opt/omics/programs/tRNAscan-SE/tRNAscan-SE/bin/ && \
    sed -i  's|infernal_dir: {bin_dir}|infernal_dir: /opt/omics/programs/infernal/infernal-1.1.2/bin/|' tRNAscan-SE.conf

