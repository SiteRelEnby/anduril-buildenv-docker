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

				# build-all.sh references `../../../bin/build.sh` which works while the anduril code is under ToyKeeper/ as in
				# the main upstream repo while build.sh is under bin/, but some forks and repos have the contents of that dir
				# (bin/, hwdefs, and the FSM dir) in the repo root instead to be cleaner, so check for that case of an incorrect
				# reference in the script, but also don't do anything automatically just in case:
				DIR=$${PWD##*/} #dirname only
				if [[ "${dir}" != "ToyKeeper" ]]
				then
					#dir structure moved to root
					if (grep '\.\.\/\.\.\/\.\.\/bin\/build.sh' build-all.sh >/dev/null)
					then
						#sed -i 's|\.\./\.\./\.\./bin/build.sh|../../bin/build.sh|' build-all.sh
						echo "build-all.sh contains '../../../bin/build.sh but root dir is not ToyKeeper; this might imply the script may need '../../build.sh instead for the dir change" >&2
						echo "If the build script doesn't work as a result, try: sed -i 's|\.\./\.\./\.\./bin/build.sh|../../bin/build.sh|' spaghetti-monster/anduril/build-all.sh" >&2
					fi

				fi
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
