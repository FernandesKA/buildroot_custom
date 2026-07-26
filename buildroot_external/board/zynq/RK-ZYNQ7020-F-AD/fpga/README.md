Drop your bitstream here as `system.bit.bin`.

It must be:

1. **Raw** (no ASCII `.bit` header) - that's what U-Boot's `zynqpl` FPGA
   driver / `fpga load` / `fpga loadfs` expect. Generate it via:

       Vivado -> Tools -> Settings -> Bitstream -> check "-bin_file"
       (or: write_bitstream -bin_file ... in a Tcl script)

2. **Uncompressed**, exactly 4045564 bytes for the XC7Z020 (check with
   `ls -l` before copying, or `fpga info 0` at the U-Boot prompt after
   copying - it prints the expected "Device Size" for comparison).
   If you build via this project's own HDL Makefile
   (`hdl/projects/fmcomms2/rk_zynq7020f`), ADI's shared build script
   (`hdl/projects/scripts/adi_project_xilinx.tcl`) enables bitstream
   compression by default, which produces a smaller file U-Boot cannot
   load. Disable it for the build:

       export ADI_NO_BITSTREAM_COMPRESSION=1
       make clean && make

   (If building from the Vivado GUI instead: Bitstream Settings ->
   uncheck "-compress".)

The resulting `<project>.runs/impl_1/system_top.bin` (or, from this HDL
project's Makefile flow, `fmcomms2_rk_zynq7020f.sdk/system_top.bin`) is
what goes here, renamed to `system.bit.bin`.

This file is intentionally not committed to git (see .gitignore) - every
board unit gets it from its own build.

U-Boot loads it automatically via CONFIG_PREBOOT (see
../uboot-config.fragment) with:

    fpga loadfs 0 0x2000000 0x800000 4045564 mmc 0:1 system.bit.bin

The "4045564" (blocksize arg) must be the exact bitstream size - it is
NOT auto-detected from the file for validation purposes, only the
filesystem read itself supports a 0-means-whole-file shortcut. See the
comment above CONFIG_PREBOOT in uboot-config.fragment for why.
