#!/system/bin/sh
exec 2>&1
ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
BOT_DIR="/home/heroku/Heroku"

[ ! -d "$ROOTFS/proc/1" ] && {
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}

if [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 АКТИВАЦИЯ"
    rm -rf "$ROOTFS/home/heroku"
    mkdir -p "$ROOTFS/home/heroku"
    
    ui_print "- Клонирование..."
    chroot $ROOTFS /usr/bin/git clone -q https://github.com/coddrago/Heroku /home/heroku/Heroku
    
    ui_print "- Установка библиотек (БЕЗ КОМПИЛЯЦИИ)..."
    # МЫ ГОВОРИМ PIP: НЕ СОБИРАЙ НИЧЕГО, ИЩИ ГОТОВОЕ
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install --upgrade pip"
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install --no-cache-dir --only-binary=:all: -r requirements.txt || /usr/bin/python3 -m pip install --no-cache-dir -r requirements.txt"
    
    ui_print "- Поиск ссылки..."
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
    ui_print " ✅ ГОТОВО. ЖМИ ACTION ЕЩЕ РАЗ."
    exit 0
fi

# Логика Старт/Стоп
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Остановка..."
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
else
    ui_print "⚙️ Запуск Heroku..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup /usr/bin/python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    ui_print "🌐 Запущен (PID: $(cat $PID_FILE))
    "
fi
