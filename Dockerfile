ARG BUILD_FROM_PREFIX

FROM ${BUILD_FROM_PREFIX}golang:alpine AS build
ARG BUILD_ARCH
ARG QEMU_ARCH
COPY .gitignore qemu-${QEMU_ARCH}-static* /usr/bin/
COPY . /src/redis-sentinel-proxy/
WORKDIR /src/redis-sentinel-proxy/
RUN CGO_ENABLED=0 GOOS=${BUILD_GOOS} GOARCH=${BUILD_GOARCH} go build \
    -ldflags '-s -w -X main.ver=${BUILD_VERSION} \
    -X main.commit=${BUILD_REF} -X main.date=${BUILD_DATE}' \
    -o .

#FROM alpine AS libs
#RUN apk --no-cache add ca-certificates

FROM scratch
#COPY --from=libs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /src/redis-sentinel-proxy/redis-sentinel-proxy /redis-sentinel-proxy
ENTRYPOINT ["/redis-sentinel-proxy"]

EXPOSE 6379

#ENV LISTEN_ADDRESS=:6379
#ENV SENTINAL_ADDRESS=sentinal:26379
#ENV REDIS_MASTER_NAME=mymaster
#ENV PASSWORD=xxxx

ARG BUILD_VERSION
ARG BUILD_DATE
ARG BUILD_REF
LABEL maintainer="Patrick Domack (patrickdk@patrickdk.com)" \
  Description="Redis Sentinal Proxy for non-sentinal aware apps" \
  ForkedFrom="" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.name="redis-sentinel-proxy" \
  org.label-schema.description="Redis Sentinal Proxy for non-sentinal aware apps" \
  org.label-schema.url="https://github.com/patrickdk77/redis-sentinel-proxy" \
  org.label-schema.usage="https://github.com/patrickdk77/redis-sentinel-proxy/tree/master/README.md" \
  org.label-schema.vcs-url="https://github.com/patrickdk77/redis-sentinel-proxy" \
  org.label-schema.vcs-ref="${BUILD_REF}" \
  org.label-schema.version="${BUILD_VERSION}"
