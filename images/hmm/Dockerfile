FROM debian as buildbase

RUN apt-get -y update && apt-get -y install git gcc make wget

RUN apt-get -y install libz-dev

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

FROM scanon/imtools:20210401

RUN apt-get -y install bc parallel

COPY --from=hmm /opt/omics /opt/omics/

RUN ln -s /opt/omics/programs/hmmer/bin/hpc_hmmsearch /opt/omics/bin/hmmsearch

