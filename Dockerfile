FROM gcr.io/etcd-development/etcd:v3.5.15 AS etcd

FROM alpine:3.20.2 AS builder

RUN apk add --no-cache wget

RUN wget https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-linux -O /usr/local/bin/b2 && \
  chmod +x /usr/local/bin/b2

FROM builder
LABEL maintainer="Eddie <jinyx007@gmail.com>"
LABEL org.opencontainers.image.source=https://github.com/jinxcappa/omni_etcd_backup
LABEL org.opencontainers.image.description="This is a simple image that contain the requirement to backup an etcd omni instance to B2."
LABEL org.opencontainers.image.licenses=WTFPL

# Copy required binaries from etcd image
COPY --from=etcd /usr/local/bin/etcdctl /usr/local/bin/etcdctl
COPY --from=etcd /usr/local/bin/etcdutl /usr/local/bin/etcdutl
COPY --from=builder /usr/local/bin/b2 /usr/local/bin/b2

RUN apk add --no-cache bash gnupg xz

ENV PATH="$PATH:/scripts"

WORKDIR /scripts

COPY backup.sh backup
RUN chmod +x backup

COPY restore.sh restore
RUN chmod +x restore

CMD [ "backup" ]
