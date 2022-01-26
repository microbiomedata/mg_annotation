FROM python:3.8.5

RUN apt-get -y update && apt-get -y install zip samtools jq

RUN \ 
    git clone https://github.com/microbiomedata/pynmdc && \
    cd pynmdc && pip install -e .

# Back-rev some packages and make sure the nmdc command still
# starts
ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && nmdc

ADD . /scripts


ENTRYPOINT "/bin/bash"
