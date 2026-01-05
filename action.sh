#!/system/bin/sh
exec 2>&1  # Теперь все ошибки будут видны на экране!

echo "--- ЗАПУСК МОДУЛЯ ---"
# остальной код...

# Обязательная функция для вывода текста в терминал Action
ui_print() {
  echo "$1"
}

ui_print "*******************************"
ui_print "   Heroku Manager Debug Mode   "
ui_print "*******************************"

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"

ui_print "- Проверка окружения..."

# Проверка наличия папки Linux
if [ ! -d "$ROOTFS" ]; then
    ui_print "❌ Ошибка: Папка Linux не найдена!"
    ui_print "Попробуйте переустановить модуль."
    exit 1
fi

# Подготовка монтирования
[ ! -d "$ROOTFS/proc/1" ] && {
    ui_print "- Монтирование системных разделов..."
    mount -o bind /dev $ROOTFS/dev
    mount -t proc proc $ROOTFS/proc
    mount -t sysfs sys $ROOTFS/sys
    mount -o bind /sdcard $ROOTFS/sdcard
}

# ЛОГИКА УСТАНОВКИ / ЗАПУСКА
if [ -f "$MODDIR/first_run" ]; then
    ui_print "🚀 Начинаем первичную установку..."
    # Твой код установки здесь...
    # (Для краткости пропустим, используй код из прошлых ответов)
    rm "$MODDIR/first_run"
    ui_print "✅ Установка завершена!"
else
    if [ -f "$PID_FILE" ]; then
        ui_print "⏹ Останавливаем бота..."
        kill -9 $(cat "$PID_FILE") 2>/dev/null
        rm "$PID_FILE"
        ui_print "Бот выключен."
    else
        ui_print "⚙️ Запуск бота в фоне..."
        chroot $ROOTFS /bin/bash -c "cd /home/heroku && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
        ui_print "🌐 Бот запущен!"
    fi
fi
