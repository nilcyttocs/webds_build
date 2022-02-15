#!/bin/bash

set -e

github=nilcyttocs
debrepo=webds_deb

q_github=qmao
q_gitrepo=syna_webds

t_github=tomc4798

source=false
debonly=false
extonly=false
version=none

dir=`readlink -f .`
pdir="$(dirname "$dir")"
ext_dir=${pdir}/jupyter/extensions
deb_dir=${pdir}/${debrepo}

echo ${ext_dir}

declare -a exts=("webds_doc_launcher"
                "webds_documentation"
                "webds_heatmap"
                "webds_launcher"
                "webds_readme"
                "webds_software_update"
                "webds_status"
                "webds_touch"
                )

declare -a q_exts=("reprogram"
                "server-extension"
                "connection-settings"
                )

declare -a t_exts=("webds_device_info")

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

Help() {
   echo "Build WebDS"
   echo "Usage: build_webds.sh [options]"
   echo
   echo "Options:"
   echo "-d     Build Debian package only"
   echo "-e     Build extensions only"
   echo "-h     Print help information"
   echo "-s     Include source distribution build"
   echo "-v     Set Debian package version"
}

Build_ext() {
    pushd ${ext_dir}

    for ext in "${exts[@]}" ; do
        echo ${ext}
        if [ ! -d ${ext_dir}/${ext} ]; then
            git clone https://github.com/${github}/${ext}.git
        else
            pushd ${ext_dir}/${ext}
            git pull https://github.com/${github}/${ext}.git
            popd
        fi
        pushd ${ext_dir}/${ext}
        git pull
        if [ ! -f tsconfig.tsbuildinfo ]; then
            pip3 install -ve .
        else
            jlpm run build
        fi
        rm -fr dist
        if [ ${source} = true ]; then
            python3 -m build
        else
            python3 -m build --wheel
        fi
        cp dist/*.whl ${deb_dir}/wheelhouse/.
        popd
    done

    popd
}

Build_qmao() {
    pushd ${ext_dir}

    echo ${ext}
    if [ ! -d ${ext_dir}/${q_gitrepo} ]; then
        git clone https://github.com/${q_github}/${q_gitrepo}.git
    else
        pushd ${ext_dir}/${q_gitrepo}
        git pull https://github.com/${q_github}/${q_gitrepo}.git
        popd
    fi
    pushd ${ext_dir}/${q_gitrepo}
    git pull
    for ext in "${q_exts[@]}" ; do
        echo ${ext}
        pushd ${ext_dir}/${q_gitrepo}/${ext}
        if [ ! -f tsconfig.tsbuildinfo ]; then
            pip3 install -ve .
        else
            jlpm run build
        fi
        rm -fr dist
        if [ ${source} = true ]; then
            python3 -m build
        else
            python3 -m build --wheel
        fi
        cp dist/*.whl ${deb_dir}/wheelhouse/.
        popd
    done
    popd

    popd
}

Build_tom() {
    pushd ${ext_dir}

    for ext in "${t_exts[@]}" ; do
        echo ${ext}
        if [ ! -d ${ext_dir}/${ext} ]; then
            git clone https://github.com/${t_github}/${ext}.git
        else
            pushd ${ext_dir}/${ext}
            git pull https://github.com/${t_github}/${ext}.git
            popd
        fi
        pushd ${ext_dir}/${ext}
        git pull
        if [ ! -f tsconfig.tsbuildinfo ]; then
            pip3 install -ve .
        else
            jlpm run build
        fi
        rm -fr dist
        if [ ${source} = true ]; then
            python3 -m build
        else
            python3 -m build --wheel
        fi
        cp dist/*.whl ${deb_dir}/wheelhouse/.
        popd
    done

    popd
}

Build_deb() {
    pushd ${deb_dir}

    if [ ${version} != "none" ]; then
        sed -i "s/^Version:.*/Version: ${version}/" control
    fi
    ./build.sh

    popd
}

while getopts ":dehsv:" option; do
   case ${option} in
      d) # build Debian package only
         debonly=true;;
      e) # build extensions only
         extonly=true;;
      h) # print help information
         Help
         exit;;
      s) # include source distribution build
         source=true;;
      v) # set Debian package version
         version=${OPTARG};;
     \?) # invalid option
         echo "Error: invalid option"
         exit;;
   esac
done

start=`date +%s`
if [ ! -d ${ext_dir} ]; then
    mkdir -p ${ext_dir}
fi
if [ ! -d ${deb_dir} ]; then
    git clone https://github.com/${github}/${debrepo}.git ${deb_dir}
else
    pushd ${deb_dir}
    git pull https://github.com/${github}/${debrepo}.git
    popd
fi
if [ ${debonly} = false ]; then
    if [ ! -d ${deb_dir}/wheelhouse ]; then
        mkdir -p ${deb_dir}/wheelhouse
    fi
    rm -fr ${deb_dir}/wheelhouse/*
    Build_ext
    Build_qmao
    Build_tom
fi
if [ ${extonly} = false ]; then
    if [ ! -d ${deb_dir}/pinormos-webds/webds-deb/var/spool/syna/jupyterlab_webds ]; then
        mkdir -p ${deb_dir}/pinormos-webds/webds-deb/var/spool/syna/jupyterlab_webds
    fi
    Build_deb
fi
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
