#!/system/bin/sh
exec 2>&1

ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
BOT_DIR="/home/heroku"

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
    
    # Очистка папки для чистого клонирования
    rm -rf "$ROOTFS$BOT_DIR"
    mkdir -p "$ROOTFS$BOT_DIR"
    
    ui_print "- Шаг 1/2 Клонирование репозитория"
    chroot $ROOTFS /usr/bin/git clone https://github.com/coddrago/Heroku $BOT_DIR
    
    ui_print "----------------------------------------"
    ui_print "- Шаг 2/2 Установка и поиск ссылки активации"

    # Используем полный путь /usr/bin/python3, чтобы избежать ошибки "not found"
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install -r requirements.txt"
    
    ui_print "⌛ Ожидание генерации ссылки..."
    
    # Запускаем скрипт и ищем URL в реальном времени
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 main.py" | while read -r line; do
        echo "$line"
        # Проверяем строку на наличие http/https
        case "$line" in
            *http*) 
                URL=$(echo "$line" | grep -oE "https?://[a-zA-Z0-9./?=_-]+")
                if [ ! -z "$URL" ]; then
                    ui_print "🌐 Ссылка найдена! Открываем..."
                    # Открываем через Android Activity Manager
                    am start -a android.intent.action.VIEW -d "$URL" >/dev/null 2>&1
                fi
                ;;
        esac
    done
    
    ui_print " ✅ Активация завершена "
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
    # Запуск в фоне с полным путем к python3
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup /usr/bin/python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    
    sleep 2
    ui_print "🌐 Heroku запущен PID $(cat $PID_FILE)"
    ui_print "📝 Логи: $BOT_DIR/bot.log"
fi
