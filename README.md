# buildroot_custom

Поддержка кастомных плат через Buildroot BR2_EXTERNAL.

## Поддерживаемые платформы

| Плата | Defconfig |
|---|---|
| Xilinx Zynq RK7020F | `zynq_rk7020f_defconfig` |
| Xilinx Zynq ADRV9002 | `zynq_adrv9002_defconfig` |
| Xilinx ZynqMP ZCU106 | `zynqmp_zcu106_defconfig` |
| Raspberry Pi 4 | `raspberrypi4_custom_defconfig` |
| Sipeed M1S | `sipeed_m1s_defconfig` |
| Sipeed M1S (ext) | `sipeed_m1s_ext_defconfig` |
| BeagleBone | `beaglebone_defconfig` |
| QEMU x86_64 | `qemu_x86_64_defconfig` |
| QEMU ARM (Zynq-7000, для отладки драйверов) | `qemu_arm_defconfig` |

## Структура репозитория
```
buildroot_custom/
├── buildroot/                  # Buildroot (submodule)
└── buildroot_external/
    ├── board/                  # DTB, U-Boot конфиги, post-build скрипты и тд
    │   ├── beagleboard/beaglebone/
    │   ├── qemu/
    │   ├── raspberrypi4_custom/
    │   ├── sipeed/m1s/
    │   ├── zynq/
    │   └── zynqmp/zcu106_custom/
    ├── boot/
    ├── configs/                # Defconfig-файлы для всех плат
    ├── package/                # Кастомные пакеты
    ├── Config.in
    ├── external.desc
    └── external.mk
```

## Быстрый старт

### 1. Клонировать с сабмодулями
```
git clone --recurse-submodules https://github.com/FernandesKA/buildroot_custom.git
cd buildroot_custom
```

Если репозиторий уже склонирован без сабмодулей:

`git submodule update --init --recursive`

### 2. Собрать образ

```bash
export BR2_EXTERNAL_FKA_PATH=$(pwd)/buildroot_external
cd buildroot
make BR2_EXTERNAL=$BR2_EXTERNAL_FKA_PATH <config_name>
make
```

Пример для Zynq RK7020F:

```bash
export BR2_EXTERNAL=$(pwd)/buildroot_external
cd buildroot
make BR2_EXTERNAL=$BR2_EXTERNAL zynq_rk7020f_defconfig
make -j$(nproc)
```

### 3. Собрать SDK (опционально)

```bash
make sdk
```

SDK-архив появится в `buildroot/output/images/` рядом с образами.

### 4. Артефакты сборки

После успешной сборки артефакты находятся в `buildroot/output/images/`. Состав зависит от платформы — как правило это образ для записи на носитель и/или отдельные бинарники (kernel, DTB, U-Boot, rootfs).

Если запускался `make sdk`, там же появится SDK-архив вида `*_sdk-buildroot.tar.gz`.

Записать образ на SD-карту:

```bash
sudo dd if=output/images/sdcard.img of=/dev/sdX bs=4M status=progress
sync
```

## CI / CD

Сборка автоматизирована через GitHub Actions на self-hosted runner.

| Событие | Результат |
|---|---|
| Push в `main` / `runner_builder` | Сборка + сохранение артефактов |
| Push тега `v*` | Сборка + публикация GitHub Release |
| `workflow_dispatch` | Ручной запуск сборки |

Готовые образы доступны на странице [Releases](https://github.com/FernandesKA/buildroot_custom/releases).

Создать релиз:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Требования для локальной сборки

Стандартные зависимости Buildroot:

```bash
# Ubuntu / Debian
sudo apt install -y \
  build-essential gcc g++ make \
  libncurses-dev bison flex \
  gettext texinfo unzip bc \
  wget cpio rsync file git
```

Полный список — [Buildroot manual §2.2](https://buildroot.org/downloads/manual/manual.html#requirement).
