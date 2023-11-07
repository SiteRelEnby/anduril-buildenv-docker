#! /usr/bin/env bash
[[ "${DEBUG}" == "1" ]] && set -x
set -e
set -o pipefail
[[ ! -d /src ]] && exit 2

usage(){
	echo 'Usage:
#    Windows CMD: docker run --rm --pull=always -v "%cd%":/src -it siterelenby/anduril-builder:latest <BUILD ARGS>
#    Linux/WSL/MacOS: docker run --rm --pull=always -v "$(pwd -P)":/src -it siterelenby/anduril-builder:latest <BUILD ARGS>

To ensure you are running the latest version of this builder, make sure "--pull=always" is included in the command line, or you can manually update with "docker pull siterelenby/anduril-builder:latest"

Special command line arguments understood by this container:
    --shell          Open a shell for debugging instead of running a build
    --install-dfp    Install the Atmel DFPs in arch/dfp (instead of relying on avr-libc)
    --debug          Enable debug output

Bug reports or support requests to https://github.com/SiteRelEnby/anduril-buildenv-docker' >&2
}

check_buildall(){
	# In the older (pre-GitHub-migration) source, build-all.sh references `../../../bin/build.sh` which works while the anduril code is under ToyKeeper/ as in
	# the main upstream repo while build.sh is under bin/, but some forks and repos have the contents of that dir
	# (bin/, hwdefs, and the FSM dir) in the repo root instead to be cleaner, so check for that case of an incorrect
	# reference in the script, but also don't do anything automatically just in case:
	if (grep '\.\.\/\.\.\/\.\.\/bin\/build.sh' ${1} >/dev/null) && ! [[ "$(pwd -P)" =~ "^/src/ToyKeeper/" ]]
	then
		#sed -i 's|\.\./\.\./\.\./bin/build.sh|../../bin/build.sh|' build-all.sh
		echo -e '\nbuild-all.sh contains "../../../bin/build.sh" but the source dir does not have "ToyKeeper/" in the root; this might imply the script may need "../../build.sh" instead for the dir change'
		echo -e "If the build script doesn't work as a result, try: sed -i 's|\.\./\.\./\.\./bin/build.sh|../../bin/build.sh|' ${dirpath}/build-all.sh\n\n\n" >&2
		#TODO: is there anything at all like sed that works for windows out of the box that's not peering into the eldritch abomination that is PowerShell?
	fi
}

# Catch the case where container was started with -e DEBUG=1, which we want to be inherited by subsequent script executions, so we need to export it
if [[ "${DEBUG}" == "1" ]]
then
	export DEBUG=1
fi

# Check args
if [[ "${#}" == "0" ]]
then
	usage
	exit 1
else
	POSITIONAL=()
	for arg in "${@}"
	do
		if [[ "${arg}" == "--shell" ]]
		then
			echo "--shell - entering interactive shell for debugging" >&2
			PS1="anduril-builder \w # " exec bash --norc
		elif [[ "${arg}" == "--install-dfp" ]]
		then
			echo "--install-dfp - installing Atmel DFPs to arch/dfp" >&2
			USE_DFP_INSTALL=1
		elif [[ "${arg}" == "--debug" ]]
		then
			set -x
			export DEBUG=1
		else
			# Store var in a temporary array to resture after we've finished parsing for builder-specific args
			POSITIONAL+=("$1")
		fi
		shift
	done
	set -- "${POSITIONAL[@]}" # restore positional parameters
fi

if [[ "${USE_DFP_INSTALL}" != "1" ]]
then
	export SKIP_DFP_INSTALL=1
fi

# Identify which version of the anduril repo (if any) we are working with
if [[ -x /src/make ]]
then
	# Newer GitHub-based repo

	# If the user specified to install the DFP, do that first
	if [[ "${USE_DFP_INSTALL}" == "1" ]]
	then
		./make dfp || exit 4
	fi

	exec ./make ${*}
elif [[ -d /src/ToyKeeper ]]
then
	# TK's original flashlight-firmware repo, or an unrestructured fork
	cd ToyKeeper/spaghetti-monster/anduril && exec build-all.sh ${*}
elif [[ -d /src/spaghetti-monster ]]
then
	# Original repo, restructured with code migrated down one level (e.g. some older GitHub-based forks)
	check_buildall spaghetti-monster/anduril/build-all.sh
        cd spaghetti-monster/anduril && exec build-all.sh ${*}
else
	# Unknown repo configuration
	echo 'Nothing in /src looks like a known anduril source directory format. If unsure what happened, run the container again with "--debug" or "-e DEBUG=1". You can also run the container with an arg of "--shell" (e.g. "docker run --rm --pull=always -v "$(pwd -P)":/src -it siterelenby/anduril-builder:latest --shell") to get an interactive shell for troubleshooting.' >&2
	usage
	[[ "${DEBUG}" == "1" ]] && find /src >&2
	exit 3
fi
