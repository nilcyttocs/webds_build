#!/bin/bash

set -e

github=nilcyttocs
webds_repo=webds

dir=`readlink -f .`
pdir="$(dirname "$dir")"
ppdir="$(dirname "$pdir")"
webds_dir=${ppdir}/${webds_repo}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

if [ ! -d ${webds_dir} ]; then
    git clone https://github.com/${github}/${webds_repo}.git ${webds_dir}
    pushd ${webds_dir}
    git submodule update --init
    popd
else
    pushd ${webds_dir}
    git pull https://github.com/${github}/${webds_repo}.git
    popd
fi

pushd ${webds_dir}
./build_webds.sh -e
popd
