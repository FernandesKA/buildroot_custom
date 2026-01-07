savedcmd_arch/riscv/boot/dts/bouffalolab/bl808-pine64-ox64.dtb := /home/fka/dev_linux/buildroot_bouffalo/buildroot/output/host/bin/ccache /usr/bin/gcc -O2 -isystem /home/fka/dev_linux/buildroot_bouffalo/buildroot/output/host/include -L/home/fka/dev_linux/buildroot_bouffalo/buildroot/output/host/lib -Wl,-rpath,/home/fka/dev_linux/buildroot_bouffalo/buildroot/output/host/lib -E -Wp,-MMD,arch/riscv/boot/dts/bouffalolab/.bl808-pine64-ox64.dtb.d.pre.tmp -nostdinc -I./scripts/dtc/include-prefixes -undef -D__DTS__ -x assembler-with-cpp -o arch/riscv/boot/dts/bouffalolab/.bl808-pine64-ox64.dtb.dts.tmp arch/riscv/boot/dts/bouffalolab/bl808-pine64-ox64.dts ; ./scripts/dtc/dtc -o arch/riscv/boot/dts/bouffalolab/bl808-pine64-ox64.dtb -b 0 -iarch/riscv/boot/dts/bouffalolab/ -i./scripts/dtc/include-prefixes -@ -Wno-interrupt_provider -Wno-unique_unit_address -Wno-unit_address_vs_reg -Wno-avoid_unnecessary_addr_size -Wno-alias_paths -Wno-graph_child_address -Wno-simple_bus_reg   -Wno-interrupt_provider -Wno-unique_unit_address -Wno-unit_address_vs_reg -Wno-avoid_unnecessary_addr_size -Wno-alias_paths -Wno-graph_child_address -Wno-simple_bus_reg   -d arch/riscv/boot/dts/bouffalolab/.bl808-pine64-ox64.dtb.d.dtc.tmp arch/riscv/boot/dts/bouffalolab/.bl808-pine64-ox64.dtb.dts.tmp ; cat arch/riscv/boot/dts/bouffalolab/.bl808-pine64-ox64.dtb.d.pre.tmp arch/riscv/boot/dts/bouffalolab/.bl808-pine64-ox64.dtb.d.dtc.tmp > arch/riscv/boot/dts/bouffalolab/.bl808-pine64-ox64.dtb.d

source_arch/riscv/boot/dts/bouffalolab/bl808-pine64-ox64.dtb := arch/riscv/boot/dts/bouffalolab/bl808-pine64-ox64.dts

deps_arch/riscv/boot/dts/bouffalolab/bl808-pine64-ox64.dtb := \
  arch/riscv/boot/dts/bouffalolab/bl808.dtsi \
  scripts/dtc/include-prefixes/dt-bindings/interrupt-controller/irq.h \
  scripts/dtc/include-prefixes/dt-bindings/mailbox/bflb-ipc.h \
  scripts/dtc/include-prefixes/dt-bindings/pinctrl/pinctrl-bflb.h \
  scripts/dtc/include-prefixes/dt-bindings/gpio/gpio.h \
  scripts/dtc/include-prefixes/dt-bindings/leds/common.h \

arch/riscv/boot/dts/bouffalolab/bl808-pine64-ox64.dtb: $(deps_arch/riscv/boot/dts/bouffalolab/bl808-pine64-ox64.dtb)

$(deps_arch/riscv/boot/dts/bouffalolab/bl808-pine64-ox64.dtb):
