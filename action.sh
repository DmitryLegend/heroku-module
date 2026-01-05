#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_userbot"
PID_FILE="$MODDIR/bot.pid"

# Подготовка окружения
[ ! -d "$ROOTFS/proc/1" ] && {
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
    mount -o bind /sdcard $ROOTFS/sdcard
}

# 1. Если это первый запуск (установка)
if [ -f "$MODDIR/first_run" ]; then
    ui_print "🚀 Установка Heroku..."
    cat <<EOF > $ROOTFS/tmp/setup.sh
#!/bin/bash
git clone https://github.com/coddrago/Heroku /home/heroku
cd /home/heroku && pip install -r requirements.txt
EOF
    chmod +x $ROOTFS/tmp/setup.sh
    chroot $ROOTFS /bin/bash /tmp/setup.sh
    rm "$MODDIR/first_run"
    ui_print "✅ Установка завершена!"
    exit 0
fi

# 2. Переключатель Вкл/Выкл
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    ui_print "🛑 Останавливаем бота (PID: $PID)..."
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
    ui_print "Бот выключен."
else
    ui_print "⚙️ Запуск юзербота..."
    # Запуск через nohup, чтобы бот не закрылся вместе с окном терминала
    chroot $ROOTFS /bin/bash -c "cd /home/heroku && nohup python3 main.py > /dev/null 2>&1 & echo \$!" > "$PID_FILE"
    ui_print "🌐 Бот запущен в фоне!
    "
fi
