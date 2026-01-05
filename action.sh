#!/system/bin/sh
# Выводим ошибки в консоль Magisk
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
BOT_DIR="/home/heroku"

# 1. МОНТИРОВАНИЕ
[ ! -d "$ROOTFS/proc/1" ] && {
    ui_print "- Монтирование систем..."
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
    mount -o bind /sdcard $ROOTFS/sdcard
}

# 2. ПРОВЕРКА УСТАНОВКИ БОТА
# Если папки бота нет — запускаем установку, игнорируя флаги
if [ ! -d "$ROOTFS$BOT_DIR" ]; then
    ui_print "🚀 Бот не найден. Начинаем установку..."
    
    cat <<EOF > $ROOTFS/tmp/setup.sh
#!/bin/bash
git clone https://github.com/coddrago/Heroku $BOT_DIR
cd $BOT_DIR
pip install --upgrade pip
pip install -r requirements.txt
EOF
    chmod +x $ROOTFS/tmp/setup.sh
    chroot $ROOTFS /bin/bash /tmp/setup.sh
    
    ui_print "✅ Установка завершена!"
    ui_print "Нажми Action еще раз для запуска."
    exit 0
fi

# 3. ЛОГИКА ВКЛ / ВЫКЛ
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        ui_print "⏹ Останавливаем бота (PID: $PID)..."
        kill -9 "$PID" 2>/dev/null
        rm "$PID_FILE"
        ui_print "✅ Бот остановлен."
    else
        ui_print "⚠️ Бот не активен, чистим PID..."
        rm "$PID_FILE"
    fi
else
    ui_print "⚙️ Запуск юзербота..."
    # Проверяем запуск и записываем PID
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    
    sleep 2
    NEW_PID=$(cat "$PID_FILE")
    if kill -0 "$NEW_PID" 2>/dev/null; then
        ui_print "🌐 Бот запущен! (PID: $NEW_PID)"
    else
        ui_print "❌ Ошибка запуска! Проверь логи в $BOT_DIR/bot.log"
    fi
fi
