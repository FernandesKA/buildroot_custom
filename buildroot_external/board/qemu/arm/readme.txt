Run the emulation with:

  qemu-system-arm -M xilinx-zynq-a9 -smp 2 -m 1G -kernel output/images/zImage -dtb output/images/zynq-zc702.dtb -drive file=output/images/rootfs.ext2,if=sd,format=raw -append "root=/dev/mmcblk0 rw rootwait console=ttyPS0,115200 earlyprintk" -serial stdio -net nic,model=cadence_gem -net user,hostfwd=tcp::2222-:22 # qemu_arm_defconfig

The login prompt will appear in the terminal that started Qemu.

This emulates a Xilinx Zynq-7000 (dual Cortex-A9), which is the SoC used by
the zynq_rk7020f_defconfig and zynq_adrv9002_defconfig boards in this tree,
so it can be used to debug the same kernel drivers without real hardware.

To attach a kernel debugger (KGDB), append "-s -S" to start-qemu.sh and
wait for the kernel to enter the debugger, or trigger it manually with
"echo g > /proc/sysrq-trigger" once Linux has booted, then connect with:

  arm-linux-gnueabihf-gdb output/build/linux-custom/vmlinux -ex "target remote :1234"
