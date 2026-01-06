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

if [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 ПЕРВИЧНЫЙ ЗАПУСК БОТА"
    rm -rf "$ROOTFS/home/heroku"
    mkdir -p "$ROOTFS/home/heroku"
    
    ui_print "▸ Шаг 1: Загрузка кода с GitHub..."
    chroot $ROOTFS /usr/bin/git clone https://github.com/coddrago/Heroku /home/heroku/Heroku
    
    ui_print "▸ Шаг 2: Установка зависимостей Python..."
    ui_print "  (Здесь собирается tgcrypto, это может занять время)"
    # Выводим стандартный лог pip, чтобы ты видел прогресс
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 -m pip install -r requirements.txt"
    
    ui_print "▸ Шаг 3: Получение ссылки авторизации..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && /usr/bin/python3 main.py" 2>&1 | while read -r line; do
        echo "$line"
        case "$line" in
            *http*) 
                URL=$(echo "$line" | grep -oE "https?://[a-zA-Z0-9./?=_-]+")
                if [ ! -z "$URL" ]; then
                    ui_print "🌐 ССЫЛКА НАЙДЕНА! ОТКРЫВАЮ БРАУЗЕР..."
                    am start -a android.intent.action.VIEW -d "$URL" >/dev/null 2>&1
                    break
                fi
                ;;
        esac
    done
    ui_print "✅ Установка окончена. Нажми Action еще раз."
    exit 0
fi

# Управление (Старт/Стоп)
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Остановка бота..."
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
else
    ui_print "⚙️ Запуск Heroku Userbot..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup /usr/bin/python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    ui_print "🌐 Бот работает в фоне (PID: $(cat $PID_FILE))"
fi
