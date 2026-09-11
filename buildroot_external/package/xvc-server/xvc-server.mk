################################################################################
#
# xvc-server
#
################################################################################

XVC_SERVER_VERSION = ee2e5ffa90e09e1dbb88071222af3724cbaeb246
XVC_SERVER_SITE = $(call github,Xilinx,XilinxVirtualCable,$(XVC_SERVER_VERSION))
XVC_SERVER_LICENSE = CC0-1.0
XVC_SERVER_LICENSE_FILES = jtag/zynqMP/src/user/README.md

define XVC_SERVER_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CROSS_COMPILE="$(TARGET_CROSS)" \
		-C $(@D)/jtag/zynqMP/src/user ioctl mmap
endef

define XVC_SERVER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/jtag/zynqMP/src/user/xvcServer_ioctl \
		$(TARGET_DIR)/usr/bin/xvcServer_ioctl
	$(INSTALL) -D -m 0755 $(@D)/jtag/zynqMP/src/user/xvcServer_mmap \
		$(TARGET_DIR)/usr/bin/xvcServer_mmap
endef

$(eval $(generic-package))
