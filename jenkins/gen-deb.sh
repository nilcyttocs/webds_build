#!/bin/bash

set -e

dir=`readlink -f .`
pdir="$(dirname "$dir")"
ppdir="$(dirname "$pdir")"

webdsdebrepo=webds_deb
webdsdeb_dir=${ppdir}/${webdsdebrepo}

jupyterlabdebrepo=jupyterlab_deb
jupyterlabdeb_dir=${ppdir}/${jupyterlabdebrepo}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

pushd ${pdir}
./build_webds.sh -d
./build_jupyterlab.sh
popd

cp ${webdsdeb_dir}/*.deb .
cp ${jupyterlabdeb_dir}/*.deb .
