#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "*******************************"
ui_print "   $MODNAME "
ui_print "   by $MODAUTH "
ui_print "*******************************"

mkdir -p $ROOTFS

ui_print "- Загрузка Alpine Linux..."
# Используем флаг -s для curl, чтобы он не спамил в лог
curl -L -s -o "$ARCHIVE" "$URL" &
CURL_PID=$!

# Анимация "Плеер" в одну строку для Magisk
symbols="/ - \ |"
while kill -0 $CURL_PID 2>/dev/null; do
    for s in $symbols; do
        # Магия: \r в echo -ne иногда работает лучше в терминалах Magisk
        echo -ne "\r  [ $s ] Скачивание образа системы..."
        sleep 0.2
    done
done
echo -e "\r  [ OK ] Загрузка завершена.          "

if [ ! -f "$ARCHIVE" ]; then
    ui_print "❌ Ошибка загрузки!"
    abort
fi

ui_print "- Распаковка и установка инструментов..."
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

# Настройка DNS
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# Установка Git и Python сразу
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl >/dev/null 2>&1

touch $MODPATH/first_run
set_perm_recursive $MODPATH 0 0 0755 0755

ui_print "✅ Всё готово! Перезагрузитесь."
