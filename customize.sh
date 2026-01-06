#!/system/bin/sh
ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "- Подготовка путей"
mkdir -p $ROOTFS

ui_print "- Загрузка Alpine Linux"
curl -L -s -o "$ARCHIVE" "$URL"

ui_print "- Распаковка системы"
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Установка инструментов (3/3)"
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf
ui_print "  Загрузка пакетов (это может занять время)..."

# Оставляем --progress для того самого красивого вывода как на скриншоте
chroot $ROOTFS /sbin/apk add --no-cache --progress python3 py3-pip git bash curl build-base python3-dev libffi-dev

set_perm_recursive $MODPATH 0 0 0755 0755
set_perm_recursive $ROOTFS 0 0 0755 0755

ui_print "****************************************"
ui_print " УСТАНОВКА ЗАВЕРШЕНА — ПЕРЕЗАГРУЗИТЕСЬ "
ui_print "****************************************"
sleep 3
