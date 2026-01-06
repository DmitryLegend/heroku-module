#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "- Подготовка путей"
mkdir -p $ROOTFS
mkdir -p $ROOTFS/home/heroku
mkdir -p $ROOTFS/var/log

ui_print "- Загрузка компонентов (1/3) Alpine Linux"
curl -L -s -o "$ARCHIVE" "$URL"

if [ ! -s "$ARCHIVE" ]; then
    ui_print "  ! Ошибка загрузки"
    abort
fi

ui_print "- Установка компонентов (2/3) Распаковка"
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Установка компонентов (3/3) Инструменты Heroku"
ui_print "  Установка Python и Git... (ожидайте)"
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# Мы убрали --progress и добавили -q (quiet), чтобы не было спама строками
if chroot $ROOTFS /sbin/apk add --no-cache -q python3 py3-pip git bash curl; then
    ui_print "  Инструменты установлены успешно"
else
    ui_print "  ! Ошибка при установке пакетов"
    abort
fi

ui_print "- Финализация прав доступа"
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
