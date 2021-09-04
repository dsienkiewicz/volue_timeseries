FROM elixir:1.12.2 AS build

# set build ENV
ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    TERM=xterm

# install build dependencies
RUN apt-get update && apt-get install -y \
    npm \
    git \
    python \
    && rm -rf /var/lib/apt/lists/*

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

COPY priv priv

# compile and build release
COPY lib lib
# COPY rel rel
RUN mix do compile, release

# prepare release image
FROM debian:buster AS app

ENV HOME=/app \
    LANG=C.UTF-8

RUN apt-get update && apt-get install -y \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

RUN chown nobody:nogroup /app
USER nobody:nogroup

COPY --from=build --chown=nobody:nogroup /app/_build/prod/rel/voluets_calculator ./
CMD ["bin/voluets_calculator", "start"]
