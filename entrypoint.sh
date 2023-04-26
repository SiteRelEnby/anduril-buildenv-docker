#! /usr/bin/env bash
[[ "${DEBUG}" == "1" ]] && set -x
set -e
set -o pipefail
[[ ! -d /src ]] && exit 2

if [[ -f /src/spaghetti-monster/anduril/build-all.sh ]] #using a version where source is in the root as opposed to under ToyKeeper/
then
	cd /src/spaghetti-monster/anduril
	exec ./build-all.sh ${*}
else
	for dirpath in spaghetti-monster/anduril2 ToyKeeper/spaghetti-monster/anduril #catch renamed anduril dir as well as default dir structure
	do
		if [[ -d "/src/${dirpath}" ]]
		then
		cd /src/${dirpath}
			if [[ -f "build-all.sh" ]]
			then
				exec ./build-all.sh ${*}
			fi
		else
			continue
		fi
	done
fi
echo "nothing in /src looks like an anduril source directory." >&2
[[ "${DEBUG}" == "1" ]] && find /src >&2
exit 1
