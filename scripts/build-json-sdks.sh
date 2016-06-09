#!/bin/sh

for conf in `cat scripts/arches.conf`; do
    IFS=':' read -a array <<< "$conf"
    arch=${array[0]}
    tune=${array[1]}
    sed -e "s/@MACHINE@/${arch}/" < conf/local.conf.template > conf/local.conf.1
    sed -e "s/@TUNE@/${tune}/" < conf/local.conf.1 > conf/local.conf
    bitbake core-image-sato
    bitbake core-image-sato -c populate_sdk_with_json
done

