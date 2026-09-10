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
ifeq ($(BR2_PACKAGE_HOST_ZYNQ_DTGEN),y)
LINUX_DEPENDENCIES += host-zynq-dtgen
UBOOT_DEPENDENCIES += host-zynq-dtgen
endif
