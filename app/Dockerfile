FROM ruby:3.0.4-alpine

WORKDIR /usr/src/app
RUN bundle init
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
COPY Rakefile .
RUN bundle exec rake -T

#WORKDIR /usr/src/app/db
#RUN bundle exec rake db:migrate
#RUN bundle exec rake db:seed
#
#WORKDIR /usr/src/app