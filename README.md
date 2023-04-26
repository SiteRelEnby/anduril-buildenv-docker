# Fork info

A fork of [anduril-buildenv-docker](https://github.com/SiteRelEnby/anduril-buildenv-docker)

* Fix bug (full path creation causes issues one some of my boxen when trying to mount a filesystem with subdirs, and is in general useless)
* Added a proper entrypoint script
  * Checks for the source directory being mounted at different paths under `/src`
  * Return non-zero on build failure

## Using the builder

A prebuilt image is available on docker hub: https://hub.docker.com/r/siterelenby/anduril-builder, or see the original README below to build a local-only version.

`docker pull siterelenby/anduril-builder:latest`. Built for amd64, armv7 and arm64 - open an issue if you need another arch and I can add it (assuming it is supported by alpine and [avr-gcc](https://www.nongnu.org/avr-libc/user-manual/overview.html)).



Original README:

# Anduril build environment

This image can be used to build Anduril, a firmware for flashlights.

It includes support for all currently used microcontrollers like the classic ATtiny85, the more advanced ATtiny1634 and the recent tinyAVR-1 series ATtiny1616.

Technical details: The image uses Alpine 3.15 as its base with the older GCC 10 because it produces smaller images than GCC 11 (or GCC 12 which doesn't work at all). Instead of the DFP (device family pack) it uses the latest development version of avr-libc which includes support for the tinyAVR series.

## How to build image

Simply run

```
DOCKER_BUILDKIT=1 docker build -t anduril-builder .
```

## How to build Anduril

```
docker run --rm -v /path/to/flashlight-firmware:/src anduril-builder [target]
```

So if you want to build for the Emisar D4Sv2 tintramp and your source is located in `/tmp/flashlight-firmware/ToyKeeper/spaghetti-monster/anduril`, run this command:

```
docker run --rm -v /tmp/flashlight-firmware:/src anduril-builder emisar-d4sv2-tintramp
```

Or to build all targets:

```
docker run --rm -v /tmp/flashlight-firmware:/src anduril-builder
```

The resulting hex files will be placed in `/tmp/flashlight-firmware/ToyKeeper/spaghetti-monster/anduril` as `anduril.target.hex`.
