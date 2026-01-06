#!/system/bin/sh
ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print " "
ui_print "📦 НАЧАЛО УСТАНОВКИ СРЕДЫ"
ui_print "--------------------------------------"

ui_print "▸ [1/4] Загрузка ядра Alpine Linux..."
curl -L -s -o "$ARCHIVE" "$URL"

ui_print "▸ [2/4] Распаковка файловой системы..."
mkdir -p $ROOTFS
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "▸ [3/4] Установка системных модулей:"
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

ui_print "  • Python 3 (основа бота)"
chroot $ROOTFS /sbin/apk add --no-cache -q python3 py3-pip

ui_print "  • GCC & Build-base (фикс ошибки tgcrypto)"
chroot $ROOTFS /sbin/apk add --no-cache -q build-base python3-dev musl-dev linux-headers

ui_print "  • Git & Bash (загрузка кода и командная среда)"
chroot $ROOTFS /sbin/apk add --no-cache -q git bash curl

ui_print "▸ [4/4] Финализация прав доступа..."
set_perm_recursive $MODPATH 0 0 0755 0755
set_perm_recursive $ROOTFS 0 0 0755 0755

ui_print "--------------------------------------"
ui_print "✅ УСТАНОВКА ЗАВЕРШЕНА"
ui_print "🚀 ПЕРЕЗАГРУЗИТЕ ТЕЛЕФОН"
ui_print "--------------------------------------"
