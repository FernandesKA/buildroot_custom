################################################################################
#
# i2c-bl808
#
################################################################################

I2C_BL808_VERSION = 1.0.0
I2C_BL808_SITE = $(BR2_EXTERNAL_STC_PATH)/package/i2c-bl808/src
I2C_BL808_SITE_METHOD = local
I2C_BL808_LICENSE = GPL-2.0
I2C_BL808_LICENSE_FILES = i2c-bl808.c

# Kernel module dependencies
I2C_BL808_DEPENDENCIES = linux

# Kernel configuration requirements
define I2C_BL808_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_I2C)
	$(call KCONFIG_ENABLE_OPT,CONFIG_I2C_BOARDINFO)
	$(call KCONFIG_ENABLE_OPT,CONFIG_OF)
	$(call KCONFIG_ENABLE_OPT,CONFIG_COMMON_CLK)
endef

# Module build environment variables
I2C_BL808_MODULE_MAKE_OPTS = \
	ARCH=$(KERNEL_ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	KERNELDIR=$(LINUX_DIR)

# No user-space components to build
define I2C_BL808_BUILD_CMDS
	# Kernel module will be built by kernel-module infrastructure
endef

# Install module to target filesystem
define I2C_BL808_INSTALL_TARGET_CMDS
	# Module installation handled by kernel-module infrastructure
endef

# Enable kernel-module and generic-package evaluation
$(eval $(kernel-module))
$(eval $(generic-package))