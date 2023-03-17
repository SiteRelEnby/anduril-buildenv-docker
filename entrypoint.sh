#! /usr/bin/env bash
[[ "${DEBUG}" == "1" ]] && set -x
set -e
set -o pipefail
[[ ! -d /src ]] && exit 2

if [[ -f /src/spaghetti-monster/anduril/build-all.sh ]]
then
	cd /src/spaghetti-monster/anduril
	exec ./build-all.sh ${*}
else
	for dirpath in anduril anduril2 ToyKeeper/anduril
	do
		if [[ -d "/src/${dirpath}" ]]
		then
		cd ${dirpath}
			if [[ -f "spaghetti-monster/anduril/build-all.sh" ]]
			then
				cd spaghetti-monster/anduril
				exec ./build-all.sh ${*}

			# put this case here to catch any restructured source. May be unnecessary but catches an edge case.
			# if the user mounts this dir into /src from the default layout it will fail though as fsm in ../ won't get pulled in.
			elif [[ -f "anduril/build-all.sh" ]]
			then
				cd anduril
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
