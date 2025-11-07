# Пакет Buildroot для драйвера I2C BL808

## Структура директорий

```
package/i2c-bl808/
├── Config.in           # Конфигурация пакета для menuconfig
├── i2c-bl808.mk        # Makefile пакета Buildroot
├── i2c-bl808.hash      # Хеши исходников (опционально)
└── src/
    ├── i2c-bl808.c     # Исходный код драйвера
    └── Makefile        # Makefile модуля ядра
```

## Config.in

```kconfig
comment "i2c-bl808 needs a Linux kernel to be built"
	depends on !BR2_LINUX_KERNEL

config BR2_PACKAGE_I2C_BL808
	bool "i2c-bl808"
	depends on BR2_LINUX_KERNEL
	help
	  I2C controller driver for Bouffalo Lab BL808 SoC.
	  
	  This driver provides I2C master functionality for the BL808
	  RISC-V based SoC, supporting standard and fast mode I2C
	  communication with interrupt-based transfers and FIFO support.
	  
	  Compatible devices: "bflb,bl808-i2c"
	  
	  https://github.com/bouffalolab
```

## i2c-bl808.mk

```makefile
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
```

## i2c-bl808.hash (опционально)

```
# Хеши для локальных исходников (если используется внешний источник)
# sha256  <hash>  i2c-bl808-1.0.0.tar.gz
```

## Makefile модуля ядра (src/Makefile)

```makefile
# Kernel module Makefile for i2c-bl808 driver

obj-m := i2c-bl808.o

# Build rules - called by Buildroot's kernel-module infrastructure
all:
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNELDIR) M=$(PWD) modules

clean:
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNELDIR) M=$(PWD) clean

modules_install:
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNELDIR) M=$(PWD) modules_install

.PHONY: all clean modules_install
```

## Интеграция в external BR2_EXTERNAL

### package/Config.in

Добавить в существующий файл:

```kconfig
menu "Custom Packages"
source "$BR2_EXTERNAL_STC_PATH/package/Config.in"
source "$BR2_EXTERNAL_STC_PATH/package/i2c-bl808/Config.in"  # Добавить эту строку
endmenu

menu "BootLoaders"
source "$BR2_EXTERNAL_STC_PATH/boot/Config.in"
endmenu

menu "Host Packages"
source "$BR2_EXTERNAL_STC_PATH/package/Config.in.host"
endmenu
```

### package/Config.in

Добавить строку:

```kconfig
source "$BR2_EXTERNAL_STC_PATH/package/cloudutils/Config.in"
source "$BR2_EXTERNAL_STC_PATH/package/blwnet_xram/Config.in"
source "$BR2_EXTERNAL_STC_PATH/package/i2c-bl808/Config.in"  # Добавить
```

### external.mk

Файл автоматически подхватит пакет благодаря wildcard:

```makefile
include $(sort $(wildcard $(BR2_EXTERNAL_STC_PATH)/package/*/*.mk))
include $(sort $(wildcard $(BR2_EXTERNAL_STC_PATH)/boot/*/*.mk))
```

## Альтернативный вариант с GitHub источником

Если исходники размещены в репозитории:

```makefile
I2C_BL808_VERSION = v1.0.0
I2C_BL808_SITE = $(call github,username,i2c-bl808-driver,$(I2C_BL808_VERSION))
I2C_BL808_LICENSE = GPL-2.0
I2C_BL808_LICENSE_FILES = LICENSE
```

## Использование

1. **Включить в конфигурации Buildroot:**
   ```bash
   make menuconfig
   # Target packages -> Custom Packages -> i2c-bl808
   ```

2. **Сборка:**
   ```bash
   make i2c-bl808
   # или
   make
   ```

3. **Проверка модуля:**
   ```bash
   # На целевой системе
   modinfo i2c-bl808
   modprobe i2c-bl808
   lsmod | grep i2c
   ```

4. **Автозагрузка:**
   ```bash
   # /etc/modules-load.d/i2c-bl808.conf
   i2c-bl808
   ```

## Device Tree интеграция

Модуль требует соответствующих узлов в Device Tree:

```dts
i2c0: i2c@20005000 {
    compatible = "bflb,bl808-i2c";
    reg = <0x20005000 0x1000>;
    interrupts = <20>;
    clocks = <&xtal>;
    clock-frequency = <100000>;
    status = "okay";
};
```

## Зависимости ядра

Пакет автоматически включает необходимые опции конфигурации ядра:
- `CONFIG_I2C=y`
- `CONFIG_I2C_BOARDINFO=y` 
- `CONFIG_OF=y`
- `CONFIG_COMMON_CLK=y`

## Отладка

```bash
# Логи модуля
dmesg | grep i2c-bl808

# Проверка устройств I2C
ls -la /dev/i2c-*
i2cdetect -l
```