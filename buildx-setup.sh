#! /usr/bin/env bash
set -e
date=$(date +%Y-%m-%d_%H%M)
init_buildx(){
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

	docker buildx rm builder
	docker buildx create --name builder --driver docker-container --use --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=52428800 #50MiB
	docker buildx inspect --bootstrap
	echo "${date}" > ${RUNDIR}/buildx
}
if [[ -d /run ]]
then
	RUNDIR="/run"
elif [[ -d /var/run ]]
then
	RUNDIR="/var/run"
elif [[ -d /tmp ]]
then
	RUNDIR="/tmp"
else
	exit 2
fi
if [[ ! -f ${RUNDIR}/buildx ]]
then
	if (docker ps | grep buildx_buildkit_builder)
	then
		echo "${date}" > ${RUNDIR}/buildx
		exit 0
	else
		init_buildx
	fi
fi
