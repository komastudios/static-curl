FROM alpine:latest AS builder
ARG TARGETARCH
ARG TARGETVARIANT
WORKDIR /build
COPY build.sh mykey.asc ./

# Map Docker platform names to expected ARCH names:
# - amd64 → amd64 (no change)
# - 386 → i386
# - arm64 → aarch64
# - arm → armv7
RUN case "${TARGETARCH}" in \
      "386") export ARCH="i386" ;; \
      "arm64") export ARCH="aarch64" ;; \
      "arm") export ARCH="armv7" ;; \
      *) export ARCH="${TARGETARCH}" ;; \
    esac && \
    ./build.sh

# Final stage: minimal image with only the static binary
FROM scratch AS export
COPY --from=builder /tmp/release/curl-* /
