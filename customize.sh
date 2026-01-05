#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
# Ссылка на минимальный образ Alpine для архитектуры процессора (arm64)
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"

ui_print "- Создание окружения..."
mkdir -p $ROOTFS

ui_print "- Скачивание Alpine Linux (около 5МБ)..."
curl -L $URL | tar -xz -C $ROOTFS

ui_print "- Базовая настройка сети..."
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# Установка необходимых пакетов внутри нашего линукса
ui_print "- Установка Python и Git внутри Alpine..."
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash

# Создаем "метку" для первого запуска
touch $MODPATH/first_run
ui_print "- Готово! После перезагрузки нажмите кнопку 'Action' для установки бота."
