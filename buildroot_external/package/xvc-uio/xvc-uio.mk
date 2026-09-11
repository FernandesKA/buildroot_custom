################################################################################
#
# xvc-uio
#
################################################################################

XVC_UIO_VERSION = 1.0
XVC_UIO_SITE = $(BR2_EXTERNAL_FKA_PATH)/package/xvc-uio/src
XVC_UIO_SITE_METHOD = local

XVC_UIO_DEPENDENCIES = linux

define XVC_UIO_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_UIO)
	$(call KCONFIG_ENABLE_OPT,CONFIG_UIO_PDRV_GENIRQ)
endef

define XVC_UIO_BUILD_CMDS
	# Nothing to build: kernel-config-only package.
endef

define XVC_UIO_INSTALL_TARGET_CMDS
	# Nothing to install: kernel-config-only package.
endef

$(eval $(generic-package))
