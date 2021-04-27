FROM debian as buildbase

RUN apt-get -y update && apt-get -y install git gcc make wget

RUN apt-get -y install libz-dev

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

FROM scanon/imtools:20210401

COPY --from=infernal /opt/omics/programs/infernal /opt/omics/programs/infernal/


