# syntax=docker/dockerfile:1.7

ARG ALPINE_VERSION=3.20
FROM alpine:${ALPINE_VERSION}

ARG TARGETARCH
ARG OPENCLAW_GATEWAY_VERSION=v1.0.0
ARG RELEASE_BASE_URL=https://github.com/openclaw/openclaw-gateway/releases/download
ARG BINARY_NAME=openclaw-gateway

RUN apk add --no-cache ca-certificates curl && \
    case "${TARGETARCH}" in \
      amd64) ARCH=amd64 ;; \
      arm64) ARCH=arm64 ;; \
      *) echo "Unsupported TARGETARCH=${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fL "${RELEASE_BASE_URL}/${OPENCLAW_GATEWAY_VERSION}/${BINARY_NAME}-linux-${ARCH}" \
      -o /usr/local/bin/${BINARY_NAME} && \
    chmod +x /usr/local/bin/${BINARY_NAME}

ENV GATEWAY_HOST=0.0.0.0 \
    GATEWAY_PORT=18789

EXPOSE 18789

ENTRYPOINT ["/usr/local/bin/openclaw-gateway"]
CMD ["serve", "--host", "0.0.0.0", "--port", "18789"]
