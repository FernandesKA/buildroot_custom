#!/bin/sh
#
# Post-image for zynq_rk7020f: assemble the A/B SD-card image and build the
# SWUpdate (.swu) bundle.

set -e

BOARD_DIR="$(dirname "$0")"

# Keep a system.dtb symlink for reference/debugging. U-Boot now loads the DTB
# from the active slot's /boot, so this symlink is not part of the boot flow.
FIRST_DT=$(sed -nr \
    -e 's|^BR2_LINUX_KERNEL_INTREE_DTS_NAME="(xilinx/)?([-_/[:alnum:]\\.]*).*"$|\2|p' \
    "${BR2_CONFIG}")
[ -z "${FIRST_DT}" ] || ln -fs "${FIRST_DT}.dtb" "${BINARIES_DIR}/system.dtb"

# Persistent /data partition (empty ext4), shared by both slots.
# 512M is enough to keep a full ~256M update.swu on the card; override with
# BR2_FKA_DATA_SIZE when generating the image.
DATA_SIZE="${BR2_FKA_DATA_SIZE:-512M}"
truncate -s "${DATA_SIZE}" "${BINARIES_DIR}/data.ext4"
"${HOST_DIR}/sbin/mkfs.ext4" -F -L data "${BINARIES_DIR}/data.ext4"

# Pre-create both U-Boot environment slots in the FAT boot partition.
# After a failed env load U-Boot's env_init() sets env_valid=ENV_VALID, so the
# first saveenv writes only the redundant file. libubootenv (fw_printenv /
# fw_setenv) refuses to start unless *both* files exist (check_env_device()
# stats each one), which would silently disable A/B boot confirmation and
# fwupdate. Empty files have a bad CRC and are replaced on the first save.
ENV_SIZE=$((0x2000))  # CONFIG_ENV_SIZE
truncate -s "${ENV_SIZE}" "${BINARIES_DIR}/uboot.env"
truncate -s "${ENV_SIZE}" "${BINARIES_DIR}/uboot-redund.env"

# Assemble the SD card image (boot + rootA + rootB + data).
support/scripts/genimage.sh -c "${BOARD_DIR}/genimage.cfg"

# Build the SWU bundle. Both install modes share the same rootfs.ext4 and
# differ only in the target partition / bootslot (see sw-description).
ROOTFS_SHA256=$(sha256sum "${BINARIES_DIR}/rootfs.ext4" | awk '{print $1}')
SWU_DIR="${BUILD_DIR}/swu"
rm -rf "${SWU_DIR}"
mkdir -p "${SWU_DIR}"
sed "s|@ROOTFS_SHA256@|${ROOTFS_SHA256}|g" \
    "${BOARD_DIR}/swupdate/sw-description" > "${SWU_DIR}/sw-description"
cp "${BINARIES_DIR}/rootfs.ext4" "${SWU_DIR}/rootfs.ext4"
( cd "${SWU_DIR}" && \
    printf 'sw-description\nrootfs.ext4\n' | cpio -ov -H crc > "${BINARIES_DIR}/update.swu" )
