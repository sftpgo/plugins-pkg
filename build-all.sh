#!/bin/bash

for ARCH in amd64 arm64 armv7 ppc64le
do
    export PLUGINS_ARCH=${ARCH}
    if [[ $ARCH == armv7 ]]; then
        export NFPM_ARCH=arm7
    else
        export NFPM_ARCH=${ARCH}
    fi
    echo ""
    echo "build for arch ${PLUGINS_ARCH}, NFPM arch ${NFPM_ARCH}"
    echo ""
    ./build.sh

    mkdir -p bundle/${NFPM_ARCH}
    cp dist-${NFPM_ARCH}/sftpgo-plugin-* bundle/${NFPM_ARCH}
done

VERSION=${PLUGINS_VERSION:-undefined}
cd bundle
tar cJvf sftpgo-plugins_${VERSION}_linux_bundle.tar.xz *
cd ..