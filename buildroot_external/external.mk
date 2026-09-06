include $(sort $(wildcard $(BR2_EXTERNAL_FKA_PATH)/package/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_FKA_PATH)/boot/*/*.mk))

# Sipeed M1s: DRM_PANEL_MIPI_DBI and SPI_BFLB are built in (=y), so the panel
# probes via request_firmware() during early kernel init, before the root
# filesystem is mounted -- the rootfs-overlay copy of the firmware file is
# unreachable at that point. CONFIG_EXTRA_FIRMWARE embeds it into vmlinux
# instead, but that requires the blob to physically exist under
# $(LINUX_DIR)/firmware/ before the kernel build starts (see
# board/sipeed/m1s/linux_defconfig for the matching CONFIG_EXTRA_FIRMWARE /
# CONFIG_EXTRA_FIRMWARE_DIR settings).
#
# NOTE: this can't use LINUX_POST_PATCH_HOOKS -- that variable is expanded
# immediately when linux/linux.mk is $(eval)'d (buildroot's top-level
# Makefile includes linux/linux.mk before it includes this br2-external
# tree's external.mk), so appending to it from here has no effect. Instead
# hook into LINUX_KCONFIG_FIXUP_CMDS, which is expanded lazily at the time
# the fixup recipe actually runs, long after all Makefiles are parsed.
ifeq ($(call qstrip,$(BR2_LINUX_KERNEL_CUSTOM_REPO_VERSION)),fc616bf273084addc89e84a6a01be809662a7c8d)
define SIPEED_M1S_LINUX_ADD_PANEL_FIRMWARE
	@mkdir -p $(@D)/firmware
	cp -f $(BR2_EXTERNAL_FKA_PATH)/board/sipeed/m1s/rootfs-overlay/lib/firmware/polcd-p169h002-ctp.bin $(@D)/firmware/
endef
LINUX_KCONFIG_FIXUP_CMDS += $(SIPEED_M1S_LINUX_ADD_PANEL_FIRMWARE)
endif
