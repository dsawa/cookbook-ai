# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.3.6

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS build

WORKDIR /app

RUN apt-get update -qq

ENV BUNDLE_PATH="/usr/local/bundle"

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY Gemfile Gemfile.lock ./

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS app

WORKDIR /app

ENV BUNDLE_PATH="/usr/local/bundle" \
    BIND=0.0.0.0

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /app /app

RUN groupadd --system --gid 1000 app && \
    useradd app --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R app:app /app

USER app

EXPOSE 9292
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "9292"]
