FROM ruby:2.7.1

WORKDIR /usr/src

RUN apt-get update && apt-get install -y \
      strace \
      netcat
