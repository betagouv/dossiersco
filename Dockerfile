FROM ruby AS base
WORKDIR /app
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install --binstubs

FROM base AS service
WORKDIR /app
COPY . .
