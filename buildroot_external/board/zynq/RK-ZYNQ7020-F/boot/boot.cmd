# zynq_rk7020f A/B boot script (compiled to boot.scr).
#
# Slot A -> /dev/mmcblk0p2
# Slot B -> /dev/mmcblk0p3
#
# Persistent state lives in the U-Boot environment (FAT, redundant):
#   bootslot          "a" | "b"   active slot
#   upgrade_available "0" | "1"   set by SWUpdate before reboot
#   bootcount / bootlimit         managed by U-Boot bootcount (rollback)
#
# bootcmd (see uboot-config.fragment) loads and sources this script.
# When U-Boot's bootcount exceeds bootlimit it runs "altbootcmd" instead,
# which flips bootslot back and re-runs bootcmd (rollback).

# First boot: initialize the slot and the rollback command, persist them.
if test -z "${bootslot}"; then
    setenv bootslot a
    setenv altbootcmd 'if test ${bootslot} = a; then setenv bootslot b; else setenv bootslot a; fi; setenv upgrade_available 0; setenv bootcount 0; saveenv; run bootcmd'
    saveenv
fi

# Map slot -> root partition number.
if test "${bootslot}" = a; then
    setenv rootpart 2
else
    setenv rootpart 3
fi

echo "A/B: booting slot ${bootslot} (root=/dev/mmcblk0p${rootpart})"

# Try the active slot first.  If its kernel or DTB is missing/corrupt,
# fall back to the other slot instead of dropping to the U-Boot prompt.
if ext4load mmc 0:${rootpart} ${kernel_addr_r} /boot/uImage; then
    if ext4load mmc 0:${rootpart} ${fdt_addr_r} /boot/system.dtb; then
        setenv bootargs console=ttyPS0,115200 root=/dev/mmcblk0p${rootpart} rw rootwait
        bootm ${kernel_addr_r} - ${fdt_addr_r}
    fi
fi

echo "A/B: slot ${bootslot} is not bootable, falling back"

if test "${bootslot}" = a; then
    setenv bootslot b
    setenv rootpart 3
else
    setenv bootslot a
    setenv rootpart 2
fi
saveenv
echo "A/B: booting slot ${bootslot} (root=/dev/mmcblk0p${rootpart})"

if ext4load mmc 0:${rootpart} ${kernel_addr_r} /boot/uImage; then
    if ext4load mmc 0:${rootpart} ${fdt_addr_r} /boot/system.dtb; then
        setenv bootargs console=ttyPS0,115200 root=/dev/mmcblk0p${rootpart} rw rootwait
        bootm ${kernel_addr_r} - ${fdt_addr_r}
    fi
fi

echo "A/B: neither slot is bootable"
