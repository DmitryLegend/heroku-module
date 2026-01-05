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

# 1. МОНТИРОВАНИЕ (УБРАЛИ SDCARD)
[ ! -d "$ROOTFS/proc/1" ] && {
    ui_print "- Подготовка системных разделов..."
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
    # Монтирование сим-карты/sdcard удалено по твоей просьбе
}

# 2. ПРОВЕРКА И УСТАНОВКА БОТА
if [ ! -d "$ROOTFS$BOT_DIR" ]; then
    ui_print "🚀 Начинаем установку юзербота..."
    
    # Запускаем клонирование в фоне для анимации
    chroot $ROOTFS /usr/bin/git clone https://github.com/coddrago/Heroku $BOT_DIR >/dev/null 2>&1 &
    GIT_PID=$!

    # Анимация "Плеер"
    symbols="/ - \ |"
    while kill -0 $GIT_PID 2>/dev/null; do
        for s in $symbols; do
            printf "\r  [ %s ] Скачивание файлов репозитория..." "$s"
            sleep 0.2
        done
    done
    ui_print ""

    ui_print "📦 Установка зависимостей Python..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && pip install --upgrade pip && pip install -r requirements.txt" >/dev/null 2>&1 &
    PIP_PID=$!

    while kill -0 $PIP_PID 2>/dev/null; do
        for s in $symbols; do
            printf "\r  [ %s ] Настройка библиотек (это долго)..." "$s"
            sleep 0.2
        done
    done
    ui_print ""
    
    ui_print "✅ Установка завершена!"
    exit 0
fi

# 3. ЛОГИКА ВКЛ / ВЫКЛ
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        ui_print "⏹ Останавливаем бота (PID: $PID)..."
        kill -9 "$PID" 2>/dev/null
        rm "$PID_FILE"
        ui_print "✅ Бот успешно выключен."
    else
        ui_print "⚠️ Процесс не найден, чистим PID..."
        rm "$PID_FILE"
    fi
else
    ui_print "⚙️ Запуск юзербота..."
    # Запуск бота в фоне
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    
    sleep 2
    NEW_PID=$(cat "$PID_FILE")
    if kill -0 "$NEW_PID" 2>/dev/null; then
        ui_print "🌐 Юзербот запущен! (PID: $NEW_PID)"
    else
        ui_print "❌ Ошибка запуска! Проверь /home/heroku/bot.log"
    fi
fi
