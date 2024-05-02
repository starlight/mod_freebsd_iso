#!/bin/sh
ISO_FILE=$1
DEST=$2

if [ ! -x /usr/local/bin/rsync ]; then
  pkg install rsync || exit 1
fi
set -ex
mdconfig -t vnode -f "$1" -u md0
MD_DIR="$(mktemp -d -p ./)"
mount -t cd9660 /dev/md0 ${MD_DIR}
rsync -a ${MD_DIR}/ "$2"
umount ${MD_DIR}
mdconfig -du md0
rmdir ${MD_DIR}
