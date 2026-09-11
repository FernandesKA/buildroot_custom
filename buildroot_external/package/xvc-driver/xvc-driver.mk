################################################################################
#
# xvc-driver
#
################################################################################

XVC_DRIVER_VERSION = ee2e5ffa90e09e1dbb88071222af3724cbaeb246
XVC_DRIVER_SITE = $(call github,Xilinx,XilinxVirtualCable,$(XVC_DRIVER_VERSION))
XVC_DRIVER_LICENSE = GPL-2.0+
XVC_DRIVER_LICENSE_FILES = jtag/zynqMP/src/driver/COPYING

XVC_DRIVER_MODULE_SUBDIRS = jtag/zynqMP/src/driver

$(eval $(kernel-module))
$(eval $(generic-package))
