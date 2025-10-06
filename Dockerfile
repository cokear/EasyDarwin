###############################################
# Builder
###############################################
FROM golang:1.23 AS builder

WORKDIR /src

# Cache modules first
COPY go.mod go.sum ./
RUN go mod download

# Copy full source
COPY . .

ARG VERSION=v0.0.0
ARG GIT_HASH=dev
ARG BUILD_TIME

RUN set -eux; \
    if [ -z "${BUILD_TIME:-}" ]; then BUILD_TIME=$(date +%s); fi; \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
      go build -trimpath \
        -ldflags="-s -w \
          -X main.buildVersion=${VERSION} \
          -X main.gitHash=${GIT_HASH} \
          -X main.buildTimeAt=${BUILD_TIME} \
          -X main.release=true" \
        -o /out/easydarwin ./cmd/server

###############################################
# Runtime
###############################################
FROM debian:bookworm-slim AS runtime

ENV TZ=Asia/Shanghai

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates tzdata; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Binary
COPY --from=builder /out/easydarwin /app/easydarwin

# Static assets and configs
COPY configs /app/configs
COPY web /app/web

# ffmpeg binary (used for snapshots/transcoding helpers)
COPY deploy/ffmpeg /app/ffmpeg
RUN chmod +x /app/ffmpeg && \
    mkdir -p /app/logs /app/stream /app/streamsvr_record/flv /app/streamsvr_record/fmp4 /app/r

# Common service ports (see configs/config.toml)
EXPOSE 10086 24434 8080 21935 25935 24935 15544 5322 25566
EXPOSE 24888/tcp 24888/udp 30000-30100/udp

VOLUME ["/app/logs", "/app/r"]

CMD ["/app/easydarwin"]