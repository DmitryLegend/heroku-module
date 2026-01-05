#!/system/bin/sh

# Определяем пути
ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"

ui_print "*******************************"
ui_print "   Heroku Userbot Installer    "
ui_print "*******************************"

# Создаем папку, если её нет
mkdir -p $ROOTFS

ui_print "- Скачивание Alpine Linux..."
# Используем curl с выводом прогресса в консоль (если Magisk поддерживает вывод)
if curl -L $URL | tar -xz -C $ROOTFS; then
    ui_print "✅ Образ успешно загружен и распакован."
else
    ui_print "❌ Ошибка при скачивании! Проверьте интернет."
    abort
fi

ui_print "- Настройка DNS и репозиториев..."
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

ui_print "- Установка системных пакетов (Python, Git)..."
# Установка пакетов внутри Chroot
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl

# Создаем флаг первого запуска
touch $MODPATH/first_run

ui_print "-------------------------------"
ui_print " ПЕРЕЗАГРУЗИТЕ ТЕЛЕФОН! "
ui_print " После загрузки нажмите 'Action' "
ui_print " в меню модулей Magisk. "
ui_print "------------------------
-------"
