#!/bin/sh
set -e

if [ -d /run/systemd/system ]; then
    if [ -n "$2" ]; then
        deb-systemd-invoke try-restart 'sftpgo.service' >/dev/null || true
    fi
fi