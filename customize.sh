#!/system/bin/sh
ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "- Подготовка путей"
mkdir -p $ROOTFS

ui_print "- Загрузка системы..."
curl -L -s -o "$ARCHIVE" "$URL"

ui_print "- Распаковка..."
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Установка зависимостей (gcc/python/git)..."
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# Используем флаг -q (quiet) для отключения спама и прогресс-баров
chroot $ROOTFS /sbin/apk add --no-cache -q python3 py3-pip git bash curl build-base python3-dev musl-dev linux-headers libffi-dev

set_perm_recursive $MODPATH 0 0 0755 0755
set_perm_recursive $ROOTFS 0 0 0755 0755

ui_print "- Готово. Перезагрузите устройство."
