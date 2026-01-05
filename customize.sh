#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

mkdir -p $ROOTFS

ui_print "- Загрузка Alpine Linux..."
curl -L -s -o "$ARCHIVE" "$URL" &
CURL_PID=$!

# Улучшенная анимация (очистка строки перед каждым выводом)
symbols="/ - \ |"
while kill -0 $CURL_PID 2>/dev/null; do
    for s in $symbols; do
        # \r возвращает в начало, \033[K стирает старую строку
        printf "\r\033[K  [ %s ] Загрузка образа системы..." "$s"
        sleep 0.2
    done
done
printf "\r\033[K  [ OK ] Загрузка завершена.\n"

ui_print "- Распаковка и установка инструментов..."
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

# Настройка сети и установка Git/Python
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl >/dev/null 2>&1

set_perm_recursive $MODPATH 0 0 0755 0755
ui_print "✅ Всё готово! Перезагрузитесь."
