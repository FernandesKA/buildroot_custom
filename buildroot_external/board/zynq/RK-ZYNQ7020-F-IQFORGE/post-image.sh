#!/bin/sh

# By default U-Boot loads DTB from a file named "system.dtb", so
# let's use a symlink with that name that points to the *first*
# devicetree listed in the config.

FIRST_DT=$(sed -nr \
               -e 's|^BR2_LINUX_KERNEL_INTREE_DTS_NAME="(xilinx/)?([-_/[:alnum:]\\.]*).*"$|\2|p' \
               "${BR2_CONFIG}")

[ -z "${FIRST_DT}" ] || ln -fs "${FIRST_DT}.dtb" "${BINARIES_DIR}/system.dtb"

BOARD_DIR="$(dirname "$0")"

# The PL fabric (dds_tx_chain_wrapper) only starts driving its LVDS
# outputs once it's actually configured. U-Boot's CONFIG_PREBOOT loads
# system.bit.bin from the boot partition and programs the PL with
# "fpga loadfs" before the kernel starts. That file is *not* produced
# by this buildroot tree - drop your Vivado-generated raw bitstream
# (Bitstream Settings -> enable "-bin_file", NOT the plain .bit with
# its ASCII header) at:
#   ${BOARD_DIR}/fpga/system.bit.bin
# If it's missing we still produce a bootable image (kernel boots,
# the PL just stays unconfigured), but warn loudly so it isn't missed
# silently in CI.
if [ -s "${BOARD_DIR}/fpga/system.bit.bin" ]; then
	cp -f "${BOARD_DIR}/fpga/system.bit.bin" "${BINARIES_DIR}/system.bit.bin"
else
	echo "WARNING: ${BOARD_DIR}/fpga/system.bit.bin missing or empty." >&2
	echo "WARNING: shipping a 0-byte placeholder - the PL fabric will not work until you supply the real bitstream and rebuild." >&2
	: > "${BINARIES_DIR}/system.bit.bin"
fi

support/scripts/genimage.sh -c "${BOARD_DIR}/genimage.cfg"
