#!/bin/bash

set -e

push=false

webds_repo=webds

dir=`readlink -f .`
pdir="$(dirname "$dir")"
webds_dir=${pdir}/${webds_repo}
webdsdeb_dir=${webds_dir}/deb_packages/webds
jupyterlabdeb_dir=${webds_dir}/deb_packages/jupyterlab

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

Help() {
   echo "Commit and Tag"
   echo "Usage: commit_and_tag.sh [options]"
   echo
   echo "Options:"
   echo "-h     Print help information"
   echo "-p     Push changes to remote repo"
}

while getopts ":hp" option; do
   case ${option} in
      h) # print help information
         Help
         exit;;
      p) # push changes to remote repo 
         push=true;;
     \?) # invalid option
         echo "Error: invalid option"
         exit;;
   esac
done

pushd ${webds_dir}
webds=$(basename -- ${webdsdeb_dir}/*.deb)
jupyterlab=$(basename -- ${jupyterlabdeb_dir}/*.deb)
tag="$(echo ${webds} | sed 's/.deb//')_$(echo ${jupyterlab} | sed 's/.deb//')"
git add .
git commit -m "${tag}"
git tag "${tag}"
if [ ${push} = true ]; then
    git push origin main
fi
popd
