#!/system/bin/sh
exec 2>&1
ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
BOT_DIR="/home/heroku/Heroku"

# Монтирование
[ ! -d "$ROOTFS/proc/1" ] && {
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}

# Шаг 1: Проверка и установка системных пакетов
if [ ! -f "$ROOTFS/usr/bin/python3" ]; then
    ui_print "⚙️ ПЕРВИЧНАЯ НАСТРОЙКА (один раз)"
    echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf
    chroot $ROOTFS /sbin/apk add --no-cache python3 py3-pip git bash curl build-base python3-dev musl-dev linux-headers libffi-dev py3-psutil
fi

# Шаг 2: Клонирование и зависимости Python
if [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 СКАЧИВАНИЕ БОТА"
    rm -rf "$ROOTFS/home/heroku"
    mkdir -p "$ROOTFS/home/heroku"
    chroot $ROOTFS /usr/bin/git clone -q https://github.com/coddrago/Heroku /home/heroku/Heroku
    
    ui_print "📦 УСТАНОВКА БИБЛИОТЕК (может занять 2-5 мин)"
    # Устанавливаем tgcrypto и остальное
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install --no-cache-dir --prefer-binary -r requirements.txt"
fi

# Шаг 3: Запуск и ссылка
if [ ! -f "$PID_FILE" ]; then
    ui_print "🔎 ПОИСК ССЫЛКИ АВТОРИЗАЦИИ..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 main.py" 2>&1 | while read -r line; do
        echo "$line"
        case "$line" in
            *http*) 
                URL=$(echo "$line" | grep -oE "https?://[a-zA-Z0-9./?=_-]+")
                if [ ! -z "$URL" ]; then
                    ui_print "🌐 ССЫЛКА НАЙДЕНА! ОТКРЫВАЮ..."
                    am start -a android.intent.action.VIEW -d "$URL" >/dev/null 2>&1
                    # Сохраняем PID, чтобы бот работал в фоне после авторизации
                    pgrep -f "python3 main.py" > "$PID_FILE"
                    break
                fi
                ;;
        esac
    done
else
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Остановка бота (PID: $PID)"
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FIL
    E"
fi
