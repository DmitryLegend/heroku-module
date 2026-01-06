#!/system/bin/sh
exec 2>&1

ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
BOT_DIR="/home/heroku"

# Монтирование только нужного
[ ! -d "$ROOTFS/proc/1" ] && {
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}
#!/system/bin/sh
# Включаем полный вывод всех процессов в консоль для первой активации
exec 2>&1

ui_print() { echo "$1"; }

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"
BOT_DIR="/home/heroku"

# 1. МОНТИРОВАНИЕ
[ ! -d "$ROOTFS/proc/1" ] && {
    ui_print "- Подготовка системных разделов"
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
}

# 2. ПЕРВАЯ АКТИВАЦИЯ (ПОЛНЫЙ ЛОГ)
if [ ! -d "$ROOTFS$BOT_DIR/Heroku" ] && [ ! -f "$ROOTFS$BOT_DIR/main.py" ]; then
    ui_print "🚀 ЗАПУСК ПЕРВОЙ АКТИВАЦИИ Heroku"
    ui_print "----------------------------------------"
    
    # Создаем папку если её нет
    mkdir -p $ROOTFS$BOT_DIR
    
    ui_print "- Шаг 1/2 Клонирование репозитория Heroku"
    # Показываем весь процесс скачивания
    chroot $ROOTFS /usr/bin/git clone --verbose https://github.com/coddrago/Heroku $BOT_DIR
    
    ui_print "----------------------------------------"
    ui_print "- Шаг 2/2 Установка зависимостей Python"
    # Показываем установку каждой библиотеки
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && pip install --upgrade pip && pip install -v -r requirements.txt"
    
    ui_print "----------------------------------------"
    ui_print " ✅ Активация завершена "
    ui_print " Нажми Action еще раз для запуска "
    exit 0
fi

# 3. ЗАПУСК И ОСТАНОВКА
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    ui_print "⏹ Останавливаем Heroku PID $PID"
    kill -9 "$PID" 2>/dev/null
    rm "$PID_FILE"
    ui_print "✅ Выключено"
else
    ui_print "⚙️ Запуск Heroku"
    # При обычном запуске логи уходят в файл
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    
    sleep 2
    ui_print "🌐 Heroku запущен PID $(cat $PID_FILE)"
    ui_print "📝 Логи сохраняются в $BOT_DIR/bot.log"
fi
"
    kill -9 $(cat "$PID_FILE") 2>/dev/null
    rm "$PID_FILE"
    ui_print "✅ Выключено."
else
    ui_print "⚙️ Запуск..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    ui_print "🌐 Запущен! PID: $(cat $PID_FILE)"
fi
