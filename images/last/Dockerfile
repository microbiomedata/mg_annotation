FROM debian as buildbase

RUN apt-get -y update && apt-get -y install git gcc make wget

RUN apt-get -y install libz-dev

# Build last 1066
#
FROM buildbase as last
ENV LAST_VER 1066
RUN apt-get -y install unzip g++

RUN \
    wget last.cbrc.jp/last-${LAST_VER}.zip &&  \
    unzip last-${LAST_VER}.zip

RUN \
    cd last-${LAST_VER} && \
    make && \
    make prefix=/opt/omics/programs/last install

FROM scanon/imtools:20210401

COPY --from=last /opt/omics/programs/last /opt/omics/programs/last/last-1066

RUN ln -s /opt/omics/programs/last/last-1066/bin/lastal /opt/omics/bin/lastal

LABEL last_ver="1066"
LABEL maintainer="bfoster@lbl.gov"
