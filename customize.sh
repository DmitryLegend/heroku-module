#!/system/bin/sh
ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "- Очистка и подготовка путей"
rm -rf $ROOTFS
mkdir -p $ROOTFS

ui_print "- Загрузка ядра Alpine Linux"
curl -L -s -o "$ARCHIVE" "$URL"

ui_print "- Распаковка системы (ждем...)"
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Установка инструментов сборки и Python"
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# Ключевой момент: устанавливаем ВСЁ ОДНОЙ КОМАНДОЙ
# Это предотвратит ошибку "gcc failed" при запуске бота
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl build-base python3-dev musl-dev linux-headers libffi-dev py3-psutil

ui_print "- Настройка разрешений"
set_perm_recursive $MODPATH 0 0 0755 0755
set_perm_recursive $ROOTFS 0 0 0755 0755

ui_print "****************************************"
ui_print " ✅ УСТАНОВКА ЗАВЕРШЕНА — ПЕРЕЗАГРУЗИТЕСЬ"
ui_print "****************************************"
