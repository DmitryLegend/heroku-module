#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "- Подготовка папок"
mkdir -p $ROOTFS

ui_print "- Загрузка компонентов (1/3) Alpine Linux"
curl -L -s -o "$ARCHIVE" "$URL"

ui_print "- Установка компонентов (2/3) Распаковка"
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Настройка путей и прав"
# Создаем домашнюю директорию и папку для логов заранее
mkdir -p $ROOTFS/home/heroku
mkdir -p $ROOTFS/var/log

ui_print "- Установка компонентов (3/3) Инструменты Heroku"
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl >/dev/null 2>&1

# Выставляем права доступа на все папки
set_perm_recursive $MODPATH 0 0 0755 0755
set_perm_recursive $ROOTFS 0 0 0755 0755

ui_print "****************************************"
ui_print " УСТАНОВКА Heroku ЗАВЕРШЕНА "
ui_print " "
ui_print " ВАЖНО "
ui_print " 1 Перезагрузите устройство "
ui_print " 2 Зайдите в Magisk "
ui_print " 3 Нажмите кнопку Action "
ui_print "****************************************"

sleep 3
