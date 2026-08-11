#!/bin/sh

# genimage will need to find the extlinux.conf in the binaries directory.
#
# Unlike the stock board/zynqmp/post-build.sh, this variant does not
# reference a root filesystem partition (e.g. /dev/mmcblk0p2). Instead
# the rootfs is loaded into RAM by U-Boot (rootfs.cpio.uboot) and used
# directly as the initramfs, so no "root=" argument is needed.

CONSOLE="$2"

mkdir -p "${BINARIES_DIR}"
cat <<-__HEADER_EOF > "${BINARIES_DIR}/extlinux.conf"
	label linux
	  kernel /Image
	  fdt /system.dtb
	  initrd /rootfs.cpio.uboot
	  append console="${CONSOLE}"
	__HEADER_EOF
