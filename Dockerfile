FROM golang:1.23 AS builder
ENV GOPROXY=https://goproxy.cn,https://proxy.golang.org,direct \
    CGO_ENABLED=1 \
    GOOS=linux \
    GOARCH=amd64
WORKDIR /src

COPY . .

# Build with version metadata
ARG VERSION=v0.0.0
ARG GIT_HASH=debug
ARG BUILD_TIME=0
# Use vendored modules to avoid network in container
RUN go build -mod=vendor -trimpath \
    -ldflags="-s -w \
      -X main.buildVersion=${VERSION} \
      -X main.gitHash=${GIT_HASH} \
      -X main.buildTimeAt=${BUILD_TIME} \
      -X main.release=true" \
    -o /out/easydarwin.com ./cmd/server

FROM golang:1.23
ENV TZ=Asia/Shanghai
WORKDIR /app

# App binary
COPY --from=builder /out/easydarwin.com ./easydarwin.com

# Runtime assets
COPY configs ./configs
COPY web ./web
COPY ffmpeg ./ffmpeg

ARG VERSION=v0.0.0
LABEL Name=EasyDarwin Version=${VERSION}

EXPOSE 10086 24434 21935 25935 24935 15544 5322 25566

CMD ["./easydarwin.com"]