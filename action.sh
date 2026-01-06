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

# 2. Активация
if [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 ПЕРВАЯ АКТИВАЦИЯ"
    rm -rf "$ROOTFS$BOT_DIR"
    mkdir -p "$ROOTFS$BOT_DIR"
    
    ui_print "- Шаг 1/2 Клонирование..."
    chroot $ROOTFS /usr/bin/git clone https://github.com/coddrago/Heroku $BOT_DIR
    
    ui_print "- Шаг 2/2 Установка зависимостей (ждем сборку)..."
    # Показываем процесс установки библиотек
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install -r requirements.txt"
    
    ui_print "⌛ Запуск и поиск ссылки..."
    
    # Запуск с перехватом ссылки и выводом в консоль
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 main.py" 2>&1 | while read -r line; do
        echo "$line"
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
    ui_print " ✅ Готово! Нажми Action еще раз "
    exit 0
fi

# 3. Управление
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Останавливаем Heroku"
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
else
    ui_print "⚙️ Запуск..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup /usr/bin/python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    sleep 2
    ui_print "🌐 Запущен PID $(cat $PID_FILE)"
fi
