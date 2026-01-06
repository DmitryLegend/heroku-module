#!/system/bin/sh
exec 2>&1
ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
BOT_DIR="/home/heroku"

# 1. Монтирование
[ ! -d "$ROOTFS/proc/1" ] && {
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}

# 2. Активация (если нет main.py)
if [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 ЗАПУСК АКТИВАЦИИ"
    rm -rf "$ROOTFS$BOT_DIR"
    mkdir -p "$ROOTFS$BOT_DIR"
    
    ui_print "- Клонирование репозитория..."
    chroot $ROOTFS /usr/bin/git clone -q https://github.com/coddrago/Heroku $BOT_DIR
    
    ui_print "- Установка библиотек (может занять время)..."
    # Ставим зависимости без лишнего вывода
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install -q --no-cache-dir -r requirements.txt"
    
    ui_print "- Запуск для получения ссылки..."
    # Запускаем и ищем URL. am start отправит его в браузер Android
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 main.py" 2>&1 | while read -r line; do
        case "$line" in
            *http*) 
                URL=$(echo "$line" | grep -oE "https?://[a-zA-Z0-9./?=_-]+")
                if [ ! -z "$URL" ]; then
                    ui_print "🌐 Ссылка найдена! Открываю..."
                    am start -a android.intent.action.VIEW -d "$URL" >/dev/null 2>&1
                    break
                fi
                ;;
        esac
    done
    ui_print "✅ Установка завершена. Нажми Action для старта."
    exit 0
fi

# 3. Управление (Старт/Стоп)
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Остановка..."
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
    ui_print "✅ Бот выключен"
else
    ui_print "⚙️ Запуск Heroku..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup /usr/bin/python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    sleep 2
    ui_print "🌐 Запущен (PID: $(cat $PID_FILE))"
fi
