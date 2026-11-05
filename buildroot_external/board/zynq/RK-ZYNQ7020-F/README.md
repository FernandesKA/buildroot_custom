# zynq_rk7020f — A/B OTA (U-Boot + SWUpdate)

Удалённое обновление по Ethernet без «окирпичивания»: на SD-карте два
независимых слота (ядро + DTB + rootfs), обновление пишется в неактивный
слот, U-Boot переключается на него и автоматически откатывается, если новый
слот не загрузился за `bootlimit` попыток.

> При переходе с обычной разметки на A/B карту нужно один раз перепрошить
> целиком (`images/sdcard.img`): меняются таблица разделов и расположение
> U-Boot environment.

## Разметка SD-карты (genimage.cfg)

```
p1  boot.vfat   boot.bin, u-boot.img, system.dtb, boot.scr
                + U-Boot env в FAT-файлах uboot.env / uboot-redund.env
p2  rootfs A    ext4 (ядро+DTB в /boot)
p3  rootfs B    ext4 (ядро+DTB в /boot)
p4  data        ext4 (персистентные данные + .swu)
```

Окружение хранится в FAT (не в raw-MMC): код платы Zynq
(`board/xilinx/zynq/board.c`) для SD-загрузки поддерживает только FAT/EXT4/
NOWHERE, и `ENV_IS_IN_MMC` приводит к `env_init() -> -ENODEV` и зависанию.
Из Linux FAT-раздел монтируется в `/uboot`, `fw_env.config` указывает на
`/uboot/uboot.env` (+ redundant-копию). Оба файла создаются в образе заранее
(`post-image.sh`): после неудачной загрузки env U-Boot ставит
`env_valid=ENV_VALID` и первый `saveenv` пишет только резервный файл, а
libubootenv (`fw_printenv`/`fw_setenv`) требует наличия обоих файлов — иначе
молча перестают работать подтверждение загрузки (`S50abconfirm`) и `fwupdate`.

## Сеть

`eth0` настраивается статически в `/etc/network/interfaces` (192.168.0.7).
`post-build.sh` добавляет в `/etc/dhcpcd.conf` строку `denyinterfaces eth0`,
чтобы dhcpcd не назначал второй адрес и не создавал конкурирующий
default-маршрут.

Загрузчик (`boot.bin`/`u-boot.img`) общий и **не обновляется по OTA** — это
единственная необновляемая точка отказа (на Zynq-7000 у BootROM нет fallback).

## Как это работает

1. **U-Boot** (`boot.cmd` → `boot.scr`): читает `bootslot`, грузит ядро и DTB
   из `/boot` активного слота, передаёт `root=/dev/mmcblk0p2|p3`.
2. **bootcount/rollback**: `CONFIG_BOOTCOUNT_ENV` + `upgrade_available`.
   SWUpdate перед перезагрузкой ставит `upgrade_available=1`, `bootcount=0` и
   переключает `bootslot`. Если слот не поднялся, watchdog сбрасывает плату,
   U-Boot инкрементирует `bootcount`, и после `bootlimit` (3) попыток
   `altbootcmd` откатывается на прежний слот.
3. **Подтверждение загрузки**: `S50abconfirm` сбрасывает `bootcount=0`.
   Watchdog (`S20watchdog`, cadence SWDT, nowayout) сбрасывает плату, если
   загрузка зависла раньше.

## Обновление

`.swu` собирается в `images/update.swu`. Внутри — `rootfs.ext4` и
`sw-description` с двумя режимами установки (`stable.to-a` / `stable.to-b`).

### Веб-интерфейс

На плате работает штатный web UI SWUpdate (Mongoose):

```
http://<ip-платы>:8080/
```

`S80swupdate` запускает демон с предвыбранным режимом неактивного слота
(на слоте A — `stable,to-b`, на слоте B — `stable,to-a`). Загрузка `.swu`
через браузер пишется сразу в неактивный слот; после установки демон
применяет `bootenv` (`bootslot`/`upgrade_available`/`bootcount`) и
перезагружает плату, а `S50abconfirm` подтверждает слот. Аутентификации нет —
интерфейс рассчитан на доверенную локальную сеть.

### CLI

```sh
scp update.swu root@<device>:/data/
ssh root@<device> fwupdate            # сам выберет неактивный слот
```

`fwupdate` читает текущий `bootslot` и вызывает
`swupdate -i ... -e stable,<to-a|to-b>`. Если web-демон запущен, образ
передаётся ему через `swupdate-client` (тот же IPC), иначе используется
отдельный `swupdate -i`.

`.swu` занимает ~256 МиБ; `/data` по умолчанию 512 МиБ (`BR2_FKA_DATA_SIZE`),
так что образ целиком помещается на плате. Можно передать его и потоком,
не сохраняя:

```sh
ssh root@<device> fwupdate - < images/update.swu
# или напрямую:
ssh root@<device> swupdate-client -e stable,to-b - < images/update.swu
```

## Логи

Логи пишутся на общий раздел `/data` и переживают переключение слота и OTA:

```
/data/logs/messages        syslog (BusyBox syslogd, ротация при 1 МиБ -> messages.0)
/data/logs/dmesg.last      dmesg текущей загрузки
/data/logs/dmesg.prev      dmesg предыдущей загрузки
/data/logs/bootinfo.last   слот, bootcount, cmdline, ip
```

Забрать всё одним архивом (через SSH):

```sh
ssh root@<device> getlogs - > logs.tar.gz
```

Посмотреть/скачать через web UI:

```
http://<device>:8080/logs/          # индекс
http://<device>:8080/logs/messages  # syslog
```

Ссылку `/var/www/swupdate/logs -> /data/logs` создаёт `S00logs`, а
`S99savelog` сохраняет dmesg и `bootinfo.last` при загрузке.

## Ключевые файлы

- `boot/boot.cmd` — A/B boot-скрипт (компилируется в `boot.scr`).
- `uboot-config.fragment` — bootcount, redundant env, watchdog, bootcmd.
- `linux-config.fragment` — cadence watchdog (nowayout).
- `swupdate/sw-description` + `swupdate/swupdate.config` — конфигурация SWUpdate.
- `post-build.sh` / `post-image.sh` / `genimage.cfg` — сборка образа и `.swu`.
- `rootfs_overlay/` — `fw_env.config`, init-скрипты, `fwupdate`, `watchdog.conf`.

## Ограничения / TODO

- `.swu` не подписан (только sha256-целостность). Для поля добавить
  `CONFIG_SIGNED_IMAGES` + ключ и подпись в `post-image.sh`.
- `rootfs.ext4` в `.swu` без сжатия (~256M). Можно gzip + `compressed = "zlib"`.
- Доставка — `scp` + `ssh`. Можно заменить на suricatta/hawkBit.
