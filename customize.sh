#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "*******************************"
ui_print "   Heroku Userbot Installer    "
ui_print "*******************************"

mkdir -p $ROOTFS

ui_print "- Загрузка Alpine Linux..."
# Запускаем загрузку в фоне
curl -L -o "$ARCHIVE" "$URL" >/dev/null 2>&1 &
CURL_PID=$!

# Анимация "Плеер" в одну строку
symbols="/ - \ |"
while kill -0 $CURL_PID 2>/dev/null; do
    for s in $symbols; do
        # \r возвращает курсор в начало, позволяя символу меняться на месте
        printf "\r  [ %s ] Загрузка образа системы..." "$s"
        sleep 0.2
    done
done
ui_print "" # Переход на новую строку после завершения

if [ ! -f "$ARCHIVE" ]; then
    ui_print "❌ Ошибка загрузки!"
    abort
fi

ui_print "- Распаковка..."
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Настройка DNS..."
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

ui_print "- Установка Git и Python..."
# Устанавливаем всё необходимое сразу, чтобы action.sh не выдавал ошибки
# Здесь тоже добавим анимацию, пока идет установка пакетов
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl >/dev/null 2>&1 &
APK_PID=$!

while kill -0 $APK_PID 2>/dev/null; do
    for s in $symbols; do
        printf "\r  [ %s ] Настройка инструментов внутри Linux..." "$s"
        sleep 0.2
    done
done
ui_print ""

# Создаем флаг и ставим права
touch $MODPATH/first_run
set_perm_recursive $MODPATH 0 0 0755 0755

ui_print "*******************************"
ui_print " ✅ УСТАНОВКА ЗАВЕРШЕНА! "
ui_print " Перезагрузите устройство. "
ui_print "*******************************"
