#!/bin/bash

NFPM_VERSION=2.41.2
NFPM_ARCH=${NFPM_ARCH:-amd64}
SUFFIX=${PLUGINS_ARCH:-amd64}
VERSION=${PLUGINS_VERSION:-undefined}

mkdir dist-${NFPM_ARCH}
echo -n ${VERSION} > dist-${NFPM_ARCH}/version
cd dist-${NFPM_ARCH}

for PLUGIN in geoipfilter kms pubsub eventstore eventsearch auth
do
    echo "download plugin from https://github.com/sftpgo/sftpgo-plugin-${PLUGIN}/releases/latest/download/sftpgo-plugin-${PLUGIN}-linux-${SUFFIX}"
    curl -L "https://github.com/sftpgo/sftpgo-plugin-${PLUGIN}/releases/latest/download/sftpgo-plugin-${PLUGIN}-linux-${SUFFIX}" --output "sftpgo-plugin-${PLUGIN}"
    chmod 755 "sftpgo-plugin-${PLUGIN}"
done

cat >nfpm.yaml <<EOF
name: "sftpgo-plugins"
arch: "${NFPM_ARCH}"
platform: "linux"
version: ${VERSION}
release: 1
section: "net"
priority: "optional"
maintainer: "Nicola Murino <nicola.murino@gmail.com>"
description: |
  Official plugins for SFTPGo
vendor: "SFTPGo"
homepage: "https://github.com/sftpgo"
license: "AGPL-3.0"
provides:
  - sftpgo-plugins
contents:
  - src: "sftpgo-plugin-*"
    dst: "/usr/bin/"

overrides:
  deb:
    scripts:
      postinstall: ../scripts/deb/postinstall.sh

  rpm:
    scripts:
      postremove: ../scripts/rpm/postremove

rpm:
  compression: xz

deb:
  compression: xz

EOF

curl --retry 5 --retry-delay 2 --connect-timeout 10 -L -O \
  https://github.com/goreleaser/nfpm/releases/download/v${NFPM_VERSION}/nfpm_${NFPM_VERSION}_Linux_x86_64.tar.gz
tar xvf nfpm_${NFPM_VERSION}_Linux_x86_64.tar.gz nfpm
chmod 755 nfpm
mkdir rpm
./nfpm -f nfpm.yaml pkg -p rpm -t rpm
mkdir deb
./nfpm -f nfpm.yaml pkg -p deb -t deb
cd ..
