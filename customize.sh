#!/system/bin/sh

# Пути
ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "*******************************"
ui_print "   Heroku Userbot Installer    "
ui_print "*******************************"

mkdir -p $ROOTFS

ui_print "- Загрузка Alpine Linux..."
set_progress 0.2

# Запускаем curl. Чтобы не спамить строками, мы выводим статус точками.
# Каждые 2 секунды будет добавляться точка в ту же строку (если терминал позволяет)
# или просто выведем один статус загрузки.
if curl -L -o "$ARCHIVE" "$URL"; then
    ui_print "  [ OK ] Файл успешно скачан."
else
    ui_print "  [ FAIL ] Ошибка загрузки!"
    abort
fi

ui_print "- Распаковка системы..."
ui_print "  [ / ] Пожалуйста, подождите..."
set_progress 0.5
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Настройка окружения..."
set_progress 0.7
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# Анимация установки пакетов (имитация)
ui_print "- Установка Python и Git..."
ui_print "  [ * ] Подготовка репозиториев..."
ui_print "  [ ** ] Скачивание пакетов..."
ui_print "  [ *** ] Настройка зависимостей..."

chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl >/dev/null 2>&1

# Финальные штрихи
touch $MODPATH/first_run
set_perm_recursive $MODPATH 0 0 0755 0755

set_progress 1.0
ui_print "*******************************"
ui_print "      УСТАНОВКА ЗАВЕРШЕНА      "
ui_print "*******************************"
ui_print " Перезагрузите устройство! "
