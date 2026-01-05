#!/system/bin/sh
exec 2>&1

ui_print() { echo "$1"; }

ui_print "*******************************"
ui_print "   Heroku Manager by @DmitryLegend "
ui_print "*******************************"

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
BOT_DIR="/home/heroku"

# Монтирование БЕЗ сим-карты/sdcard
[ ! -d "$ROOTFS/proc/1" ] && {
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}

if [ ! -d "$ROOTFS$BOT_DIR" ]; then
    ui_print "🚀 Установка бота..."
    
    # Клонирование
    chroot $ROOTFS /usr/bin/git clone https://github.com/coddrago/Heroku $BOT_DIR >/dev/null 2>&1
    
    ui_print "📦 Настройка библиотек..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && pip install --upgrade pip && pip install -r requirements.txt" >/dev/null 2>&1
    
    ui_print "✅ Установка завершена!"
    exit 0
fi

# Логика запуска
if [ -f "$PID_FILE" ]; then
    ui_print "⏹ Остановка..."
    kill -9 $(cat "$PID_FILE") 2>/dev/null
    rm "$PID_FILE"
    ui_print "✅ Бот выключен."
else
    ui_print "⚙️ Запуск..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    ui_print "🌐 Запущен! PID: $(cat $PID_FILE)"
fi
