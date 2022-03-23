#!/bin/bash

set -e

webds_repo=webds

dir=`readlink -f .`
pdir="$(dirname "$dir")"
ppdir="$(dirname "$pdir")"
webds_dir=${ppdir}/${webds_repo}
webdsdeb_dir=${webds_dir}/deb_packages/webds
jupyterlabdeb_dir=${webds_dir}/deb_packages/jupyterlab

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

pushd ${webds_dir}
./build_webds.sh -d
./build_jupyterlab.sh
popd

cp ${webdsdeb_dir}/*.deb .
cp ${jupyterlabdeb_dir}/*.deb .
