#!/system/bin/sh

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_userbot"
PID_FILE="$MODDIR/bot.pid"

# Функция для подготовки Linux к работе
prepare_linux() {
    [ ! -d "$ROOTFS/proc/1" ] && {
        mount -o bind /dev $ROOTFS/dev
        mount -t proc proc $ROOTFS/proc
        mount -t sysfs sys $ROOTFS/sys
        mount -o bind /sdcard $ROOTFS/sdcard
    }
}

prepare_linux

# СЦЕНАРИЙ 1: САМЫЙ ПЕРВЫЙ ЗАПУСК (Установка Heroku)
if [ -f "$MODDIR/first_run" ]; then
    ui_print "--- НАЧАЛО УСТАНОВКИ HEROKU ---"
    
    # Создаем временный скрипт установки внутри Alpine
    cat <<EOF > $ROOTFS/tmp/setup.sh
#!/bin/bash
echo "Клонирование репозитория..."
git clone https://github.com/coddrago/Heroku /home/heroku
cd /home/heroku
echo "Установка зависимостей (это может быть долго)..."
pip install -r requirements.txt
echo "Установка завершена!"
EOF

    chmod +x $ROOTFS/tmp/setup.sh
    chroot $ROOTFS /bin/bash /tmp/setup.sh
    
    rm "$MODDIR/first_run"
    ui_print "--- ВСЕ ГОТОВО! НАЖМИТЕ ACTION СНОВА ДЛЯ ЗАПУСКА ---"
    exit 0
fi

# СЦЕНАРИЙ 2: ПЕРЕКЛЮЧАТЕЛЬ (ВКЛ / ВЫКЛ)
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        ui_print "Выключение юзербота (PID: $PID)..."
        kill "$PID"
        rm "$PID_FILE"
        ui_print "Бот остановлен."
    else
        ui_print "Бот упал или был закрыт. Очистка..."
        rm "$PID_FILE"
    fi
else
    ui_print "Запуск юзербота..."
    # Запускаем Python в фоновом режиме через nohup
    chroot $ROOTFS /bin/bash -c "cd /home/heroku && nohup python3 main.py > /dev/null 2>&1 & echo \$!" > "$PID_FILE"
    ui_print "Бот запущен в фоне!"
fi
