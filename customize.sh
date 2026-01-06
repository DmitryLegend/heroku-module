#!/system/bin/sh
ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print "- Полная очистка среды"
rm -rf $ROOTFS
mkdir -p $ROOTFS

ui_print "- Загрузка и распаковка Alpine"
curl -L -s -o "$ARCHIVE" "$URL"
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

ui_print "- Установка системных пакетов"
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# Ставим по очереди, чтобы не перегружать систему
chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl
chroot $ROOTFS /sbin/apk add --no-cache build-base python3-dev musl-dev linux-headers libffi-dev
chroot $ROOTFS /sbin/apk add --no-cache py3-psutil py3-pillow py3-cryptography

ui_print "- Настройка прав"
set_perm_recursive $MODPATH 0 0 0755 0755
set_perm_recursive $ROOTFS 0 0 0755 0755

ui_print "✅ СИСТЕМА ГОТОВА. ПЕРЕЗАГРУЗИСЬ."
