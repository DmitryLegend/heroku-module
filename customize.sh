#!/system/bin/sh
ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "- Очистка старой среды..."
rm -rf $ROOTFS
mkdir -p $ROOTFS

ui_print "- Скачивание Alpine..."
curl -L -s -o "$ARCHIVE" "$URL"

ui_print "- Распаковка системы..."
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Установка системных пакетов (Шаг 1)..."
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf
# Устанавливаем базовый софт
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl

ui_print "- Установка инструментов сборки (Шаг 2)..."
# Устанавливаем GCC и PSUTIL отдельно, чтобы не перегружать память
chroot $ROOTFS /sbin/apk add --no-cache build-base python3-dev musl-dev linux-headers libffi-dev py3-psutil

ui_print "- Настройка прав..."
set_perm_recursive $MODPATH 0 0 0755 0755
set_perm_recursive $ROOTFS 0 0 0755 0755

ui_print "--------------------------------------"
ui_print " ✅ УСТАНОВКА ЗАВЕРШЕНА"
ui_print " 🚀 ПЕРЕЗАГРУЗИТЕ ТЕЛЕФОН"
ui_print "--------------------------------
------"
