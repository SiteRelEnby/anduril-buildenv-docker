FROM alpine:3.15 AS avr-libc-builder

RUN apk update \
  && apk --no-cache add gcc-avr alpine-sdk sudo python3 \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && abuild-keygen -ain

COPY APKBUILD_avr-libc /avr-libc-git/APKBUILD
WORKDIR /avr-libc-git/
RUN abuild -F checksum \
  && abuild -rF



FROM alpine:3.15

COPY entrypoint.sh /entrypoint.sh

RUN --mount=from=avr-libc-builder,source=/root/packages,target=/packages \
  apk --no-cache --allow-untrusted add bash grep perl make /packages/*/avr-libc*.apk

ENV ATTINY_DFP=/not/existing
#RUN mkdir -p /src/ToyKeeper/spaghetti-monster/anduril
#WORKDIR /src/ToyKeeper/spaghetti-monster/anduril
RUN mkdir /src
WORKDIR /src
#ENTRYPOINT ["./build-all.sh"]
ENTRYPOINT ["/entrypoint.sh"]
