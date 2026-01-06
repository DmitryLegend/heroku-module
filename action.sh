#!/system/bin/sh
exec 2>&1
ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
# Важно: git clone создает папку Heroku внутри /home/heroku/
BOT_DIR="/home/heroku/Heroku"

# Монтирование системных разделов
[ ! -d "$ROOTFS/proc/1" ] && {
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}

if [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 ПЕРВАЯ АКТИВАЦИЯ"
    rm -rf "$ROOTFS/home/heroku"
    mkdir -p "$ROOTFS/home/heroku"
    
    ui_print "- Клонирование репозитория..."
    chroot $ROOTFS /usr/bin/git clone -q https://github.com/coddrago/Heroku /home/heroku/Heroku
    
    ui_print "- Установка Python-зависимостей..."
    # --prefer-binary заставит использовать уже установленный нами в customize.sh py3-psutil
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install --no-cache-dir --prefer-binary -r requirements.txt"
    
    ui_print "- Запуск и получение ссылки..."
    # Объединяем вывод, чтобы точно поймать URL
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 main.py" 2>&1 | while read -r line; do
        echo "$line"
        case "$line" in
            *http*) 
                URL=$(echo "$line" | grep -oE "https?://[a-zA-Z0-9./?=_-]+")
                if [ ! -z "$URL" ]; then
                    ui_print "🌐 Ссылка найдена! Открываю в браузере..."
                    am start -a android.intent.action.VIEW -d "$URL" >/dev/null 2>&1
                    break
                fi
                ;;
        esac
    done
    ui_print " ✅ Готово! Нажми Action еще раз для старта."
    exit 0
fi

# Управление процессом
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Останавливаем Heroku..."
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
else
    ui_print "⚙️ Запуск бота в фоне..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup /usr/bin/python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    ui_print "🌐 Бот запущен (PID: $(cat $PID_FILE))
    "
fi
