#!/system/bin/sh

# Перенаправляем все ошибки в стандартный вывод, чтобы они отображались в Magisk
exec 2>&1

# Функция для вывода текста (в Action используется обычный echo)
ui_print() {
  echo "$1"
}

ui_print "*******************************"
ui_print "   Heroku Userbot Manager      "
ui_print "*******************************"

ROOTFS="/data/local/linux_bot"
MODDIR="/data/adb/modules/heroku_module"
PID_FILE="$MODDIR/bot.pid"

# 1. ПРОВЕРКА ОКРУЖЕНИЯ
if [ ! -d "$ROOTFS" ]; then
    ui_print "❌ Ошибка: Alpine Linux не найден!"
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

# 2. ПЕРВАЯ УСТАНОВКА HEROKU
if [ -f "$MODDIR/first_run" ]; then
    ui_print "🚀 Начинаем установку Heroku..."
    
    # Скрипт установки внутри Linux
    cat <<EOF > $ROOTFS/tmp/setup.sh
#!/bin/bash
if [ ! -d "/home/heroku" ]; then
    git clone https://github.com/coddrago/Heroku /home/heroku
fi
cd /home/heroku
pip install --upgrade pip
pip install -r requirements.txt
EOF
    chmod +x $ROOTFS/tmp/setup.sh
    
    # Запуск установки через chroot
    chroot $ROOTFS /bin/bash /tmp/setup.sh
    
    rm "$MODDIR/first_run"
    ui_print "✅ Установка завершена!"
    ui_print "Нажмите 'Action' еще раз для запуска."
    exit 0
fi

# 3. ЛОГИКА ВКЛЮЧЕНИЯ / ВЫКЛЮЧЕНИЯ (ПЕРЕКЛЮЧАТЕЛЬ)
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    # Проверяем, жив ли процесс
    if kill -0 "$PID" 2>/dev
