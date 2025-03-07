# syntax=docker/dockerfile:1
# check=error=true

ARG NODE_VERSION=23.5.0
FROM docker.io/library/node:$NODE_VERSION-slim AS build

WORKDIR /app

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY package*.json ./

RUN npm install

COPY . .

FROM docker.io/library/node:$NODE_VERSION-slim AS app

ENV BIND=0.0.0.0

WORKDIR /app

COPY --from=build /app /app

RUN groupadd --system --gid 1001 app && \
    useradd app --uid 1001 --gid 1001 --create-home --shell /bin/bash && \
    chown -R app:app /app

USER app

EXPOSE 5173
CMD ["npm", "run", "dev"]
