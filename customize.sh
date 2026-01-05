#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "- Подготовка окружения..."
mkdir -p $ROOTFS

ui_print "- Загрузка компонентов (1/3): Alpine Linux"
if curl -L -s -o "$ARCHIVE" "$URL"; then
    ui_print "  [ OK ] Образ системы получен."
else
    ui_print "  [ FAIL ] Ошибка загрузки."
    abort
fi

ui_print "- Установка компонентов (2/3): Распаковка ROOTFS"
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Настройка сети и DNS..."
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

ui_print "- Установка компонентов (3/3): Системные пакеты"
ui_print "  [ > ] Установка: python3, pip, git, bash"
# Устанавливаем всё необходимое сразу
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl >/dev/null 2>&1

set_perm_recursive $MODPATH 0 0 0755 0755
ui_print "*******************************"
ui_print " ✅ УСТАНОВКА ЗАВЕРШЕНА! "
ui_print " Автор: @DmitryLegend "
ui_print "*******************************"
