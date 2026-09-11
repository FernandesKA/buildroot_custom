################################################################################
#
# zynq-dtgen
#
# Generates a Zynq/ZynqMP root DTS + PL devicetree overlay from a Vivado
# .xsa, via Xilinx's xsct + the device-tree-xlnx generator (which is what
# this "package" actually downloads - there's nothing to build/install on
# the target, only host-side dts generation).
#
################################################################################

ZYNQ_DTGEN_VERSION = $(call qstrip,$(BR2_PACKAGE_HOST_ZYNQ_DTGEN_DEVICE_TREE_XLNX_VERSION))
ZYNQ_DTGEN_SITE = https://github.com/Xilinx/device-tree-xlnx.git
ZYNQ_DTGEN_SITE_METHOD = git
ZYNQ_DTGEN_LICENSE = BSD-3-Clause

ZYNQ_DTGEN_XSA = $(call qstrip,$(BR2_PACKAGE_HOST_ZYNQ_DTGEN_XSA_PATH))
ZYNQ_DTGEN_XSCT = $(call qstrip,$(BR2_PACKAGE_HOST_ZYNQ_DTGEN_XSCT))
ZYNQ_DTGEN_DTS_NAME = $(call qstrip,$(BR2_PACKAGE_HOST_ZYNQ_DTGEN_DTS_NAME))
ZYNQ_DTGEN_FALLBACK_DIR = $(call qstrip,$(BR2_PACKAGE_HOST_ZYNQ_DTGEN_FALLBACK_DIR))

# Fixed, version-independent location, so BR2_LINUX_KERNEL_CUSTOM_DTS_DIR /
# BR2_TARGET_UBOOT_CUSTOM_DTS_PATH can reference it without knowing this
# package's own (versioned) build directory.
ZYNQ_DTGEN_OUTPUT_DIR = $(BUILD_DIR)/zynq-dtgen/output

define HOST_ZYNQ_DTGEN_BUILD_CMDS
	$(BR2_EXTERNAL_FKA_PATH)/package/zynq-dtgen/gen-dts.sh \
		"$(ZYNQ_DTGEN_XSCT)" \
		"$(ZYNQ_DTGEN_XSA)" \
		"$(@D)" \
		"$(ZYNQ_DTGEN_DTS_NAME)" \
		"$(ZYNQ_DTGEN_FALLBACK_DIR)" \
		"$(ZYNQ_DTGEN_OUTPUT_DIR)"
endef

# Nothing to install - gen-dts.sh already wrote everything build needs
# straight to ZYNQ_DTGEN_OUTPUT_DIR.
define HOST_ZYNQ_DTGEN_INSTALL_CMDS
	:
endef

$(eval $(host-generic-package))

# Make sure the dts/overlay exist before the kernel/u-boot try to copy them
# in. Re-run "make host-zynq-dtgen-dirclean host-zynq-dtgen" after changing
# the .xsa - like the custom-dts-dir mechanism itself, this isn't wired into
# incremental rebuilds automatically.
#
# NOTE: this can't use LINUX_DEPENDENCIES/UBOOT_DEPENDENCIES - by the time
# this file is included (br2-external's package/*/*.mk, pulled in via
# external.mk), linux/linux.mk and boot/uboot/uboot.mk have already been
# $(eval)'d, which has already expanded $(LINUX_FINAL_DEPENDENCIES) /
# $(UBOOT_FINAL_DEPENDENCIES) into the literal prerequisite list of their
# ".stamp_configured" rule (GNU Make expands a rule's prerequisites when the
# rule is parsed, not when it runs). Appending to *_DEPENDENCIES here happens
# too late to be seen by that already-generated rule, so host-zynq-dtgen
# silently never gets built - this is the same class of ordering issue
# documented above for LINUX_POST_PATCH_HOOKS/LINUX_KCONFIG_FIXUP_CMDS.
#
# Instead, add an extra prerequisite line for the existing ".stamp_configured"
# targets directly: GNU Make merges prerequisites from multiple rules for the
# same target, so this works regardless of include order, as long as
# $(LINUX_TARGET_CONFIGURE)/$(UBOOT_TARGET_CONFIGURE) already have their final
# value here (they do - both are plain $(BUILD_DIR)/<pkg>/.stamp_configured
# paths fixed by linux.mk/uboot.mk well before this file is read).
ifeq ($(BR2_PACKAGE_HOST_ZYNQ_DTGEN),y)
ifeq ($(BR2_LINUX_KERNEL),y)
$(LINUX_TARGET_CONFIGURE): | host-zynq-dtgen
endif
ifeq ($(BR2_TARGET_UBOOT),y)
$(UBOOT_TARGET_CONFIGURE): | host-zynq-dtgen
endif
endif
