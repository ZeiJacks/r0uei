FROM ruby:3.0.4-alpine

RUN apk --no-cache --update add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

WORKDIR /usr/src/app
RUN bundle init
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
COPY Rakefile .
RUN bundle exec rake -T
