Drop your bitstream here as `system.bit.bin`.

It must be:

1. **Raw** (no ASCII `.bit` header) - that's what U-Boot's `zynqpl` FPGA
   driver / `fpga load` / `fpga loadfs` expect. Generate it via:

       Vivado -> Tools -> Settings -> Bitstream -> check "-bin_file"
       (or: write_bitstream -bin_file ... in a Tcl script)

2. **Uncompressed**, exactly 4045564 bytes for the XC7Z020 (check with
   `ls -l` before copying, or `fpga info 0` at the U-Boot prompt after
   copying - it prints the expected "Device Size" for comparison).
   Disable bitstream compression in the Vivado project settings before
   generating the bitstream (Bitstream Settings -> uncheck "-compress"),
   otherwise U-Boot cannot load it.

The resulting `<project>.runs/impl_1/zynq_rk7020_ps_wrapper.bin` (or
whichever top-level wrapper this project's Vivado run produces) is what
goes here, renamed to `system.bit.bin`.

This file is intentionally not committed to git (see .gitignore) - every
board unit gets it from its own build.

U-Boot loads it automatically via CONFIG_PREBOOT (see
../uboot-config.fragment) with:

    fpga loadfs 0 0x2000000 0x800000 4045564 mmc 0:1 system.bit.bin

The "4045564" (blocksize arg) must be the exact bitstream size - it is
NOT auto-detected from the file for validation purposes, only the
filesystem read itself supports a 0-means-whole-file shortcut. See the
comment above CONFIG_PREBOOT in uboot-config.fragment for why.
