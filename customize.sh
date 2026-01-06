#!/system/bin/sh
ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print " "
ui_print "📦 ПОДГОТОВКА ЯДРА"
ui_print "--------------------------------------"
ui_print "▸ Шаг 1: Создание папок..."
mkdir -p $ROOTFS

ui_print "▸ Шаг 2: Загрузка базы Alpine..."
curl -L -s -o "$ARCHIVE" "$URL"

ui_print "▸ Шаг 3: Распаковка ядра..."
tar -xzf "$ARCHIVE" -C $ROOTFS
rm "$ARCHIVE"

set_perm_recursive $MODPATH 0 0 0755 0755
set_perm_recursive $ROOTFS 0 0 0755 0755

ui_print "--------------------------------------"
ui_print "✅ БАЗА ГОТОВА"
ui_print "🚀 ТЕПЕРЬ ПЕРЕЗАГРУЗИСЬ И НАЖМИ ACTION"
ui_print " "
