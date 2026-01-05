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

if [ ! -d "$ROOTFS$BOT_DIR" ]; then
    ui_print "🚀 Установка юзербота от @codrago..."
    
    # Клонирование с анимацией
    chroot $ROOTFS /usr/bin/git clone https://github.com/coddrago/Heroku $BOT_DIR >/dev/null 2>&1 &
    GIT_PID=$!
    
    symbols="/ - \ |"
    while kill -0 $GIT_PID 2>/dev/null; do
        for s in $symbols; do
            printf "\r\033[K  [ %s ] Клонирование репозитория..." "$s"
            sleep 0.2
        done
    done
    printf "\r\033[K  [ OK ] Репозиторий скачан.\n"
    
    ui_print "📦 Установка библиотек..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && pip install --upgrade pip && pip install -r requirements.txt" >/dev/null 2>&1 &
    PIP_PID=$!
    
    while kill -0 $PIP_PID 2>/dev/null; do
        for s in $symbols; do
            printf "\r\033[K  [ %s ] Настройка Python среды..." "$s"
            sleep 0.2
        done
    done
    printf "\r\033[K  [ OK ] Библиотеки установлены.\n"
    
    exit 0
fi

# Логика запуска
if [ -f "$PID_FILE" ]; then
    ui_print "⏹ Останавливаем бота..."
    kill -9 $(cat "$PID_FILE") 2>/dev/null
    rm "$PID_FILE"
    ui_print "✅ Выключено."
else
    ui_print "⚙️ Запуск..."
    chroot $ROOTFS /bin/bash -c "cd $BOT_DIR && nohup python3 main.py > bot.log 2>&1 & echo \$!" > "$PID_FILE"
    ui_print "🌐 Запущен! PID: $(cat $PID_FILE)"
fi
