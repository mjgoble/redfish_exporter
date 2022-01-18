FROM docker.io/library/centos:7 AS builder

LABEL maintainer="Matt Goble <matt.goble@hotmail.co.nz>"

ARG ARCH=amd64

ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH "$GOROOT/bin:$GOPATH/bin:$PATH"
ENV GO_VERSION 1.15.2
ENV GO111MODULE=on 


# Build dependencies

RUN yum update -y && \
    yum install -y  rpm-build make  git && \
    curl -SL https://dl.google.com/go/go${GO_VERSION}.linux-${ARCH}.tar.gz | tar -xzC /usr/local 
RUN mkdir -p /go/src/github.com/ && \
    git clone https://github.com/mjgoble/redfish_exporter /go/src/github.com/mjgoble/redfish_exporter && \
    cd /go/src/github.com/mjgoble/redfish_exporter && \
    make build

FROM docker.io/library/centos:7

COPY --from=builder /go/src/github.com/mjgoble/redfish_exporter/build/redfish_exporter /usr/local/bin/redfish_exporter
RUN mkdir /etc/prometheus
COPY config.yml.example /etc/prometheus/redfish_exporter.yml
CMD ["/usr/local/bin/redfish_exporter","--config.file","/etc/prometheus/redfish_exporter.yml"]


