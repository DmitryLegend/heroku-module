#!/system/bin/sh

# Ждем полной загрузки системы, чтобы сеть успела подняться
sleep 30

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"

# Подготовка окружения (монтирование)
mount_fs() {
    [ ! -d "$ROOTFS/proc/1" ] && {
        mount -o bind /dev $ROOTFS/dev
        mount -t proc proc $ROOTFS/proc
        mount -t sysfs sys $ROOTFS/sys
        mount -o bind /sdcard $ROOTFS/sdcard
    }
}

# Если установка уже была завершена (нет флага first_run)
if [ ! -f "$MODDIR/first_run" ]; then
    mount_fs
    # Запуск бота в фоне
    chroot $ROOTFS /bin/bash -c "cd /home/heroku && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE
    "
fi
