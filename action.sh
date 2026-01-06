#!/system/bin/sh
exec 2>&1

ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
BOT_DIR="/home/heroku"
# Ссылка, которую нужно открыть
URL_TO_OPEN="https://github.com/coddrago/Heroku"

# 1. МОНТИРОВАНИЕ
[ ! -d "$ROOTFS/proc/1" ] && {
    ui_print "- Подготовка системных разделов"
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}

# 2. ПЕРВАЯ АКТИВАЦИЯ
if [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 ЗАПУСК ПЕРВОЙ АКТИВАЦИИ Heroku"
    ui_print "----------------------------------------"
    
    rm -rf "$ROOTFS$BOT_DIR"
    mkdir -p "$ROOTFS$BOT_DIR"
    
    ui_print "- Шаг 1/2 Клонирование репозитория Heroku"
    chroot $ROOTFS /usr/bin/git clone https://github.com/coddrago/Heroku $BOT_DIR
    
    ui_print "----------------------------------------"
    ui_print "- Шаг 2/2 Установка зависимостей Python"
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && python3 -m pip install --upgrade pip && python3 -m pip install -r requirements.txt"
    
    ui_print "----------------------------------------"
    ui_print " ✅ Активация завершена "
    
    # АВТО-ОТКРЫТИЕ ССЫЛКИ
    ui_print "🌐 Открываем браузер модуля..."
    # Используем Android Activity Manager для запуска браузера по умолчанию
    am start -a android.intent.action.VIEW -d "$URL_TO_OPEN" >/dev/null 2>&1
    
    ui_print " Нажми Action еще раз для запуска "
    exit 0
fi

# 3. ЗАПУСК И ОСТАНОВКА
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Останавливаем Heroku PID $PID"
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
    ui_print "✅ Выключено"
else
    ui_print "⚙️ Запуск Heroku"
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    
    sleep 2
    ui_print "🌐 Heroku запущен PID $(cat $PID_FILE)"
    ui_print "📝 Логи: $BOT_DIR/bot.log"
fi
