FROM ruby:2.4.1-stretch
RUN apt-get update
COPY . /usr/src/leanback
WORKDIR /usr/src/leanback
RUN bundle install
