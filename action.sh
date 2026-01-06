#!/system/bin/sh
exec 2>&1
ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
# [span_12](start_span)[span_13](start_span)Путь, где реально лежит main.py после клонирования[span_12](end_span)[span_13](end_span)
BOT_DIR="/home/heroku/Heroku"

[ ! -d "$ROOTFS/proc/1" ] && {
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}

if [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 АКТИВАЦИЯ"
    # [span_14](start_span)Очищаем перед клонированием[span_14](end_span)
    rm -rf "$ROOTFS/home/heroku"
    mkdir -p "$ROOTFS/home/heroku"
    
    ui_print "- Скачивание репозитория..."
    [span_15](start_span)chroot $ROOTFS /usr/bin/git clone -q https://github.com/coddrago/Heroku /home/heroku/Heroku[span_15](end_span)
    
    ui_print "- Установка зависимостей..."
    # [span_16](start_span)[span_17](start_span)Используем --prefer-binary, чтобы не пытаться собирать psutil заново[span_16](end_span)[span_17](end_span)
    [span_18](start_span)chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install -q --no-cache-dir --prefer-binary -r requirements.txt"[span_18](end_span)
    
    ui_print "- Запуск для получения ссылки..."
    # [span_19](start_span)Запускаем и ловим URL[span_19](end_span)
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 main.py" 2>&1 | while read -r line; do
        echo "$line"
        case "$line" in
            *http*) 
                URL=$(echo "$line" | grep -oE "https?://[a-zA-Z0-9./?=_-]+")
                if [ ! -z "$URL" ]; then
                    ui_print "🌐 Ссылка найдена! Открываю браузер..."
                    am start -a android.intent.action.VIEW -d "$URL" >/dev/null 2>&1
                    break
                fi
                ;;
        esac
    done
    ui_print " ✅ Установка завершена. Нажми Action для старта "
    exit 0
fi

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Остановка..."
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
else
    ui_print "⚙️ Запуск Heroku..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup /usr/bin/python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    sleep 2
    ui_print "🌐 Запущен (PID: $(cat $PID_FILE))"
fi
