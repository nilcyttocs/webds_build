#!/bin/bash

set -e

github=nilcyttocs
debrepo=jupyterlab_deb

version=none

dir=`readlink -f .`
pdir="$(dirname "$dir")"
deb_dir=${pdir}/${debrepo}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

Help() {
   echo "Build JupyterLab"
   echo "Usage: build_jupyterlab.sh [options]"
   echo
   echo "Options:"
   echo "-h     Print help information"
   echo "-v     Set Debian package version"
}

Build_deb() {
    pushd ${deb_dir}

    if [ ${version} != "none" ]; then
        sed -i "s/^Version:.*/Version: ${version}/" control
    fi
    ./build.sh

    popd
}

while getopts ":hv:" option; do
   case ${option} in
      h) # print help information
         Help
         exit;;
      v) # set Debian package version
         version=${OPTARG};;
     \?) # invalid option
         echo "Error: invalid option"
         exit;;
   esac
done

start=`date +%s`
if [ ! -d ${deb_dir} ]; then
    git clone https://github.com/${github}/${debrepo}.git ${deb_dir}
else
    pushd ${deb_dir}
    git pull https://github.com/${github}/${debrepo}.git
    popd
fi
if [ ! -d ${deb_dir}/pinormos-jupyterlab/jupyterlab-deb/var/spool/syna/jupyterlab_wheels ]; then
    mkdir -p ${deb_dir}/pinormos-jupyterlab/jupyterlab-deb/var/spool/syna/jupyterlab_wheels
fi
Build_deb
end=`date +%s`
runtime=$((end-start))
echo
if [ ${runtime} -gt 60 ]; then
    minutes=$((${runtime}/60))
    seconds=$((${runtime}%60))
    echo Done in ${minutes}m${seconds}s
else
    echo Done in ${runtime}s
fi
echo
