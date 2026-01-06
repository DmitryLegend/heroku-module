#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

# ШАГ 0: Принудительное создание структуры
ui_print "- Подготовка путей"
mkdir -p $ROOTFS
mkdir -p $ROOTFS/home/heroku
mkdir -p $ROOTFS/var/log

ui_print "- Загрузка компонентов (1/3) Alpine Linux"
curl -L -s -o "$ARCHIVE" "$URL"

if [ ! -s "$ARCHIVE" ]; then
    ui_print "  ! Ошибка: Файл не скачан"
    abort
fi

ui_print "- Установка компонентов (2/3) Распаковка"
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Установка компонентов (3/3) Инструменты Heroku"
ui_print "  Загрузка пакетов (это может занять время)"
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# Добавили вывод каждой операции, чтобы видеть прогресс
chroot $ROOTFS /sbin/apk add --no-cache --progress python3 py3-pip git bash curl

# Фиксация прав в реальной системе
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
