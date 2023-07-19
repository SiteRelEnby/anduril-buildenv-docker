#! /usr/bin/env bash
[[ "${DEBUG}" == "1" ]] && set -x
set -e
set -o pipefail
[[ ! -d /src ]] && exit 2

check_buildall(){
	# build-all.sh references `../../../bin/build.sh` which works while the anduril code is under ToyKeeper/ as in
	# the main upstream repo while build.sh is under bin/, but some forks and repos have the contents of that dir
	# (bin/, hwdefs, and the FSM dir) in the repo root instead to be cleaner, so check for that case of an incorrect
	# reference in the script, but also don't do anything automatically just in case:
	if (grep '\.\.\/\.\.\/\.\.\/bin\/build.sh' build-all.sh >/dev/null)
	then
		#sed -i 's|\.\./\.\./\.\./bin/build.sh|../../bin/build.sh|' build-all.sh
		echo -e "\n\n\nbuild-all.sh contains '../../../bin/build.sh but root dir is not ToyKeeper; this might imply the script may need '../../build.sh instead for the dir change" >&2
		echo -e "If the build script doesn't work as a result, try: sed -i 's|\.\./\.\./\.\./bin/build.sh|../../bin/build.sh|' ${dirpath}/build-all.sh\n\n\n" >&2
		#TODO: is there anything at all like sed that works for windows out of the box that's not peering into the eldritch abomination that is PowerShell?
	fi
}

for dirpath in spaghetti-monster/anduril spaghetti-monster/anduril2 spaghetti-monster/anduril2 ToyKeeper/spaghetti-monster/anduril #catch renamed anduril dir as well as default dir structure
do
	if [[ -d "/src/${dirpath}" ]]
	then
		cd /src/${dirpath}
		check_buildall
		exec ./build-all.sh ${*}
	fi
done
echo -e '# Nothing in /src looks like an anduril source directory. If unsure what happened, run the container again with `-e DEBUG=1`\n\nIn general, to run the image with the correct filesystem available to it, try one of these simple oneliners:\n    # Windows CMD: `docker run --rm --pull=always -v "%cd%":/src -it siterelenby/anduril-builder:latest`\n    # Linux/WSL/MacOS: `sudo docker run --rm --pull=always -v "$(pwd -P)":/src -it siterelenby/anduril-builder:latest`\n\n# To make sure you are runing the latest version of this builder, make sure `--pull=always` is included in the command line, or you can manually update with `docker pull siterelenby/anduril-builder:latest`'
[[ "${DEBUG}" == "1" ]] && find /src >&2
exit 1
