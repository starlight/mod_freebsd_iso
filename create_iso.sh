#!/bin/sh
ISO_OLD=$1
SOURCE=$2
ISO_NEW=$3

if [ ! -x /usr/local/bin/mkisofs ]; then
  pkg install cdrtools || exit 1
fi
set -ex
ISO_LABEL="$(file ${ISO_OLD} | awk -F\' '{print $2}')"
mkisofs -J -r -no-emul-boot \
  -V "$ISO_LABEL" \
  -p $(whoami) -b boot/cdboot \
  -o "${ISO_NEW}" "${SOURCE}"

