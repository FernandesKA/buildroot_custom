
Данные проект предоставляет поддержку плат на базе актуального buildroot, расширяя функциональность через BR2_EXTERNAL.

В данном проекте поддержаны конфигурации таких плат, как:

1. raspberrypi4_custom_defconfig
2. sipeed_m1s_defcofconfig
3. zcu106_custom_defconfig

Как собрать образ?

```
git clone --recurse-submodules git@gitlab.stc-spb.ru:ohs/buildroot_custom.git
export BR2_EXTERNAL_STC_PATH=$(pwd)/buildroot_external
cd buildroot
make BR2_EXTERNAL=$BR2_EXTERNAL_STC_PATH <config_name>
make
```
