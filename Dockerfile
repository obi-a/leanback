FROM ruby:2.4.1-stretch
RUN apt-get update
COPY . /usr/src/leanback
WORKDIR /usr/src/leanback
ADD ~/.ssh/id_rsa /tmp/
RUN ssh-agent /tmp
# RUN bundle install or similar command
RUN rm /tmp/id_rsa
RUN bundle install
