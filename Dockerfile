# Build Knock from repo with Docker to avoid dependency hell on your host
# machine. The multistage build produces a slim scratch-based container with
# only the Knock binary.
#
# Building:
# docker build -t knock .
#
# Usage example for satellite-dish-trouble.acsm in current directory:
# docker run -v "$PWD":/tmp knock /tmp/satellite-dish-trouble.acsm

ARG NIX_VERSION=2.11.1
ARG BUILD_DIR=/usr/local/build/nix

FROM nixos/nix:$NIX_VERSION AS builder
ARG BUILD_DIR
WORKDIR /etc/nix
RUN echo 'experimental-features = nix-command flakes' >> nix.conf
WORKDIR "$BUILD_DIR"
COPY . ./
RUN nix build

FROM [scratch](busybox:1.35-musl)
ARG BUILD_DIR
COPY --from=builder "$BUILD_DIR"/result/bin/knock /
ENTRYPOINT ["/knock"]
