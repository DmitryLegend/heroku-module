#!/system/bin/sh

# Определение путей
ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "*******************************"
ui_print "   Heroku Userbot Installer    "
ui_print "*******************************"

# Создаем папку
mkdir -p $ROOTFS

ui_print "- Начинаем загрузку Alpine Linux..."
ui_print "  Это может занять время..."

# Запускаем загрузку в фоне
curl -L -o "$ARCHIVE" "$URL" >/dev/null 2>&1 &
CURL_PID=$!

# Анимация "Плеер-Спиннер"
symbols="/ - \ |"
set_progress 0.1

while kill -0 $CURL_PID 2>/dev/null; do
    for s in $symbols; do
        # Выводим динамическую строку
        echo -ne "\r  Загрузка [ $s ] Соединение активно..."
        sleep 0.2
    done
done

# Проверка результата загрузки
if [ ! -f "$ARCHIVE" ]; then
    ui_print ""
    ui_print "❌ Ошибка: Файл не скачался!"
    abort
fi

ui_print ""
ui_print "✅ Загрузка завершена. Распаковка..."
set_progress 0.5

# Распаковка
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Настройка DNS..."
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

ui_print "- Установка системных пакетов..."
set_progress 0.8
# Установка базового софта
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl >/dev/null 2>&1

# Создаем флаг первого запуска и выставляем права
touch $MODPATH/first_run
set_perm_recursive $MODPATH 0 0 0755 0755

set_progress 1.0
ui_print "-------------------------------"
ui_print " ✅ ВСЁ ГОТОВО! "
ui_print " 1. Перезагрузите телефон. "
ui_print " 2. Нажмите 'Action' в Magisk. "
ui_print "-------------------------------"
