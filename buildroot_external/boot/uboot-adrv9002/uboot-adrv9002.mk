define UBOOT_ADRV9002_SETUP
	mkdir -p $(UBOOT_SRCDIR)/board/xilinx/zynq/zynq-adrv9002
	cp $(BR2_EXTERNAL_FKA_PATH)/board/zynq/adrv9002/ps7_init/ps7_init_gpl.* \
		$(UBOOT_SRCDIR)/board/xilinx/zynq/zynq-adrv9002/
endef
UBOOT_PRE_BUILD_HOOKS += UBOOT_ADRV9002_SETUP
