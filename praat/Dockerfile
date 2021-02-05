FROM alpine

LABEL MAINTAINER="Berend Weel b.weel@esciencecenter.nl"

ENV PRAAT_VER 6138

RUN wget http://www.fon.hum.uva.nl/praat/praat${PRAAT_VER}_linux64barren.tar.gz \
    && tar xzf praat${PRAAT_VER}_linux64barren.tar.gz -C /usr/bin \
    && rm praat${PRAAT_VER}_linux64barren.tar.gz

COPY . /app
WORKDIR /app

CMD ["/bin/sh"]

