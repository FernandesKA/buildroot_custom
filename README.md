
Данные проект предоставляет поддержку плат на базе актуального buildroot для кастомных внутренних проектов, расширяя функциональность через BR2_EXTERNAL.

В данном проекте поддержаны конфигурации таких плат, как:

1. raspberrypi4_custom_defconfig
2. sipeed_m1s_defcofconfig
3. zcu106_custom_defconfig
4. qemu_x86_64_otus_defconfig


Как собрать образ?

```
export BR2_EXTERNAL_FKA_PATH=$(pwd)/buildroot_external
cd buildroot
make BR2_EXTERNAL=$BR2_EXTERNAL_FKA_PATH <config_name>
make
```
