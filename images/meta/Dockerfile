FROM python:3

RUN \ 
    git clone https://github.com/microbiomedata/pynmdc && \
    cd pynmdc && pip install -e .

ADD . /scripts
ENTRYPOINT "/bin/bash"
