# config
ARCH=amd64
VERSION=14.0
BASE=https://download.freebsd.org/releases/$(ARCH)/$(ARCH)/ISO-IMAGES/$(VERSION)
SHA_FIL=CHECKSUM.SHA512-FreeBSD-$(VERSION)-RELEASE-$(ARCH)
IMG_REL=FreeBSD-$(VERSION)-RELEASE-$(ARCH)-memstick.img
IMG_MOD=FreeBSD-$(VERSION)-MODIFIED-$(ARCH)-memstick.img

.PHONY: all

all: $(IMG_MOD)

# download freebsd img, check sha512
$(IMG_REL):
	@fetch -a -r -R "$(BASE)/$(IMG_REL).xz"
	@fetch -a -m "$(BASE)/$(SHA_FIL)"
	@echo "SHA512 Check..."
	@sha512sum --ignore-missing -c "$(SHA_FIL)"
	@echo "Decompressing XZ..."
	@xz -dvf -T 0 "$(IMG_REL).xz"

$(IMG_MOD): $(IMG_REL)
	@echo "Creating $(IMG_MOD)..."
	cp "$(IMG_REL)" "$(IMG_MOD)"
	sudo mdconfig -au md0 -t vnode -f "${IMG_MOD}"
	mkdir -p ./media
	sudo mount /dev/md0s2a ./media
	sudo cp src/installer/etc/installerconfig ./media/etc/
	sudo tar -C src/distribution -cJf ./media/usr/freebsd-dist/distribution.txz .
	sudo umount ./media
	sudo mdconfig -du md0
