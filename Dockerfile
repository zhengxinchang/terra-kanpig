FROM ubuntu:22.04
RUN mkdir -p /software/
COPY ./src/kanpig /software/
COPY ./assets /

