#!/system/bin/sh
exec 2>&1
ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
BOT_DIR="/home/heroku/Heroku"

# Монтирование системы
[ ! -d "$ROOTFS/proc/1" ] && {
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}

# ШАГ 1: Установка системных компонентов (если их нет)
if [ ! -f "$ROOTFS/usr/bin/python3" ]; then
    ui_print "⚙️ НАСТРОЙКА СИСТЕМЫ (один раз)"
    echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf
    
    ui_print "▸ Установка Python 3 (движок бота)..."
    chroot $ROOTFS /sbin/apk add --no-cache -q python3 py3-pip
    
    ui_print "▸ Установка GCC и Build-base (инструменты для tgcrypto)..."
    chroot $ROOTFS /sbin/apk add --no-cache -q build-base python3-dev musl-dev linux-headers libffi-dev
    
    ui_print "▸ Установка Git и Curl (для загрузки файлов)..."
    chroot $ROOTFS /sbin/apk add --no-cache -q git curl bash
fi

# ШАГ 2: Клонирование и зависимости
if [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 ЗАГРУЗКА БОТА"
    rm -rf "$ROOTFS/home/heroku"
    mkdir -p "$ROOTFS/home/heroku"
    
    ui_print "▸ Клонирование GitHub..."
    chroot $ROOTFS /usr/bin/git clone -q https://github.com/coddrago/Heroku /home/heroku/Heroku
    
    ui_print "▸ Установка библиотек (может занять 3-5 минут)..."
    # Показываем лог pip, чтобы видеть прогресс сборки tgcrypto
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install -r requirements.txt"
fi

# ШАГ 3: Запуск и ссылка
if [ ! -f "$PID_FILE" ]; then
    ui_print "🔎 ПОИСК ССЫЛКИ АВТОРИЗАЦИИ..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 main.py" 2>&1 | while read -r line; do
        echo "$line"
        case "$line" in
            *http*) 
                URL=$(echo "$line" | grep -oE "https?://[a-zA-Z0-9./?=_-]+")
                if [ ! -z "$URL" ]; then
                    ui_print "🌐 НАШЕЛ! ОТКРЫВАЮ БРАУЗЕР..."
                    am start -a android.intent.action.VIEW -d "$URL" >/dev/null 2>&1
                    # Сохраняем PID
                    pgrep -f "python3 main.py" > "$PID_FILE"
                    break
                fi
                ;;
        esac
    done
    ui_print "✅ ГОТОВО! Бот настроен."
else
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Остановка бота (PID: $PID)"
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
fi
