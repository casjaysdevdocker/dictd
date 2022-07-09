FROM casjaysdevdocker/debian:latest as dictbuild

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -yy apt-utils locales dialog
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
RUN apt-get update && apt-get install -yy net-tools procps dictd* dict-* && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./etc/dictd/. /etc/dictd/
COPY ./etc/default/dictd /etc/default/dictd
COPY ./usr/bin/entrypoint.sh /usr/bin/entrypoint.sh

RUN mkdir -p /var/log/dictd && touch /var/log/dictd/server.log && chmod -Rfv 777 /etc/dictd /var/log/dictd

FROM dictbuild
ARG BUILD_DATE="$(date +'%Y-%m-%d %H:%M')" 

LABEL \
  org.label-schema.name="dictd" \
  org.label-schema.description="Dictionary server" \
  org.label-schema.url="https://hub.docker.com/r/casjaysdevdocker/dictd" \
  org.label-schema.vcs-url="https://github.com/casjaysdevdocker/dictd" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.version=$BUILD_DATE \
  org.label-schema.vcs-ref=$BUILD_DATE \
  org.label-schema.license="WTFPL" \
  org.label-schema.vcs-type="Git" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="CasjaysDev" \
  maintainer="CasjaysDev <docker-admin@casjaysdev.com>" 

ENV HOSTNAME dictd

EXPOSE 2628

VOLUME [ "/config" ]

HEALTHCHECK CMD ["/usr/bin/entrypoint.sh", "healthcheck"]

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
