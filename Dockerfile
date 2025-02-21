FROM ghcr.io/linuxserver/baseimage-alpine:3.15

# set version label
ARG UNRAR_VERSION=6.1.7
ARG BUILD_DATE
ARG VERSION
ARG MEDUSA_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV LANG='en_US.UTF-8'

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    make \
    g++ \
    gcc && \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache \
    curl \
    mediainfo \
    py3-chardet \
    py3-idna \
    py3-openssl \
    py3-urllib3 \
    python3 && \
  echo "**** install unrar from source ****" && \
  mkdir /tmp/unrar && \
  curl -o \
    /tmp/unrar.tar.gz -L \
    "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" && \  
  tar xf \
    /tmp/unrar.tar.gz -C \
    /tmp/unrar --strip-components=1 && \
  cd /tmp/unrar && \
  make && \
  install -v -m755 unrar /usr/bin && \
  echo "**** install app ****" && \
  if [ -z ${MEDUSA_RELEASE+x} ]; then \
    MEDUSA_RELEASE=$(curl -sX GET "https://api.github.com/repos/pymedusa/Medusa/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  mkdir -p \
    /app/medusa && \
  curl -o \
    /tmp/medusa.tar.gz -L \
    "https://github.com/pymedusa/Medusa/archive/${MEDUSA_RELEASE}.tar.gz" && \
  tar xf /tmp/medusa.tar.gz -C \
    /app/medusa --strip-components=1 && \
  echo "**** clean up ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8081
VOLUME /config
