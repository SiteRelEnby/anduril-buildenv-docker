#! /usr/bin/env bash
set -e

usage(){
	echo "REPOSITORY=foo IMAGE_NAME=bar IMAGE_TAG=latest ${0}" >&2
}

[[ -z "${REPOSITORY}" ]] && usage && exit 1
[[ -z "${IMAGE_NAME}" ]] && usage && exit 1
[[ -z "${IMAGE_TAG}" ]] && usage && exit 1

./buildx-setup.sh

if [[ -n "${BUILD_ARGS}" ]]
then
	docker buildx build --platform linux/arm/v7,linux/amd64,linux/arm64 --push "${BUILD_ARGS}" --tag "${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}" . || exit 1
else
	docker buildx build --platform linux/arm/v7,linux/amd64,linux/arm64 --push --tag "${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}" . || exit 1
fi
