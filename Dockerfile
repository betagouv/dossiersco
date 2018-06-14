FROM ruby AS base
WORKDIR /app
COPY Gemfile .
COPY Gemfile.lock .
RUN apt-get install libsqlite3-dev && bundle install

FROM base AS service
WORKDIR /app
COPY . .
