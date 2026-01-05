#!/system/bin/sh
# Перенаправляем ошибки в консоль Magisk
exec 2>&1

ui_print() {
  echo "$1"
}

ui_print "*******************************"
ui_print "   Heroku Userbot Manager      "
ui_print "*******************************"

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"

# 1. ПОДГОТОВКА
if [ ! -d "$ROOTFS" ]; then
    ui_print "❌ Alpine Linux не найден!"
    exit 1
fi

# Монтирование
[ ! -d "$ROOTFS/proc/1" ] && {
    ui_print "- Монтирование систем..."
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
    mount -o bind /sdcard $ROOTFS/sdcard
}

# 2. УСТАНОВКА ИЛИ ЗАПУСК
if [ -f "$MODDIR/first_run" ]; then
    ui_print "🚀 Начинаем установку..."
    
    # Создаем скрипт установки внутри Linux
    cat <<EOF > $ROOTFS/tmp/setup.sh
#!/bin/bash
git clone https://github.com/coddrago/Heroku /home/heroku
cd /home/heroku
pip install --upgrade pip
pip install -r requirements.txt
EOF
    chmod +x $ROOTFS/tmp/setup.sh
    
    # Запуск установки
    chroot $ROOTFS /bin/bash /tmp/setup.sh
    
    rm "$MODDIR/first_run"
    ui_print "✅ Установка завершена!"
    ui_print "Нажми Action снова для запуска."
else
    # ЛОГИКА ВКЛ / ВЫКЛ
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            ui_print "⏹ Останавливаем бота (PID: $PID)..."
            kill -9 "$PID" 2>/dev/null
            rm "$PID_FILE"
            ui_print "✅ Бот выключен."
        else
            ui_print "⚠️ Бот не найден, чистим файл..."
            rm "$PID_FILE"
        fi
    else
        ui_print "⚙️ Запуск юзербота..."
        # Запуск через nohup
        chroot $ROOTFS /bin/bash -c "cd /home/heroku && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
        
        sleep 2
        NEW_PID=$(cat "$PID_FILE")
        if kill -0 "$NEW_PID" 2>/dev/null; then
            ui_print "🌐 Бот запущен! (PID: $NEW_PID)"
        else
            ui_print "❌ Ошибка запуска! См. /home/heroku/bot.log"
        fi
    fi
fi
