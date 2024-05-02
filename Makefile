# config
ARCH=amd64
VERSION=14.0
BASE=https://download.freebsd.org/releases/$(ARCH)/$(ARCH)/ISO-IMAGES/$(VERSION)
SHA_FIL=CHECKSUM.SHA512-FreeBSD-$(VERSION)-RELEASE-$(ARCH)
ISO_REL=FreeBSD-$(VERSION)-RELEASE-$(ARCH)-disc1.iso
ISO_DIR=media
INS_FIL=etc/installerconfig
DST_FIL=usr/freebsd-dist/distribution.txz
ISO_MOD=FreeBSD-$(VERSION)-MODIFIED-$(ARCH)-disc1.iso

.PHONY: all clean

all: $(ISO_MOD)

clean:
	sudo rm -rf "$(ISO_DIR)" "$(ISO_MOD)"

# download freebsd iso, check sha512
$(ISO_REL):
	@fetch -a -r -R $(BASE)/$(ISO_REL).xz
	@fetch -a -m $(BASE)/$(SHA_FIL)
	@echo "SHA512 Check..."
	@sha512sum --ignore-missing -c $(SHA_FIL)
	@echo "Decompressing XZ..."
	@xz -dvf -T 0 $(ISO_REL).xz

# extract iso contents
$(ISO_DIR)/COPYRIGHT: $(ISO_REL)
	sudo ./extract_iso.sh "$(ISO_REL)" "$(ISO_DIR)"

$(ISO_DIR)/$(INS_FIL): src/installer/$(INS_FIL) $(ISO_DIR)/COPYRIGHT
	sudo rsync -a src/installer/ "$(ISO_DIR)"

# prepare distribution file
$(ISO_DIR)/$(DST_FIL): src/distribution/.keep $(ISO_DIR)/COPYRIGHT
	sudo tar -C src/distribution -cJf $@ .

# create modified iso
$(ISO_MOD): $(ISO_DIR)/$(DST_FIL) $(ISO_DIR)/$(INS_FIL)
	sudo ./create_iso.sh "$(ISO_REL)" "$(ISO_DIR)" "$(ISO_MOD)"

