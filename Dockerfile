FROM python:2

LABEL Maintainer "Keith McDuffee <gudlyf@realistek.com>"

RUN apt update && apt -y install \
  automake-1.15 \
  bash \
  libtre-dev \
  libxml2-dev \
  strace

RUN pip install lxml

WORKDIR /usr/local
RUN git clone https://github.com/egnor/nutrimatic.git

WORKDIR /usr/local/nutrimatic

RUN ./build.py
