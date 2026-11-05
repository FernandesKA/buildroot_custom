#!/bin/sh
#
# Post-build for zynq_rk7020f: make each rootfs slot self-contained by
# installing the kernel and device tree into /boot of the rootfs, so U-Boot
# loads them from the active slot partition (see boot.cmd).

set -e

# Determine the DTB base name from BR2_LINUX_KERNEL_INTREE_DTS_NAME
# (e.g. "xilinx/foo" -> "foo", "xilinx/zynq-rk7020f" -> "zynq-rk7020f").
FIRST_DT=$(sed -nr \
    -e 's|^BR2_LINUX_KERNEL_INTREE_DTS_NAME="(xilinx/)?([-_/[:alnum:]\\.]*).*"$|\2|p' \
    "${BR2_CONFIG}")
DTB_NAME="${FIRST_DT##*/}"

install -D -m 0644 "${BINARIES_DIR}/uImage" "${TARGET_DIR}/boot/uImage"
install -D -m 0644 "${BINARIES_DIR}/${DTB_NAME}.dtb" "${TARGET_DIR}/boot/system.dtb"

# eth0 is configured statically in /etc/network/interfaces. Keep dhcpcd from
# adding a second address and a competing default route to the same interface.
if [ -f "${TARGET_DIR}/etc/dhcpcd.conf" ] && \
   ! grep -qx 'denyinterfaces eth0' "${TARGET_DIR}/etc/dhcpcd.conf"; then
	printf '\n# eth0 is managed by ifupdown (static); do not touch it.\ndenyinterfaces eth0\n' \
		>> "${TARGET_DIR}/etc/dhcpcd.conf"
fi
