#!/system/bin/sh

# Функция для имитации процесса установки конкретного компонента
install_step() {
    local message="$1"
    local command="$2"
    ui_print "  [..] $message"
    eval "$command" >/dev/null 2>&1 &
    local PID=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps -p $PID -o comm=)" ]; do
        local temp=${spinstr#?}
        printf "  [%c]" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
    printf "  [OK]\n"
}

ROOTFS="/data/local/linux_bot"
URL="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.4-aarch64.tar.gz"
ARCHIVE="$MODPATH/alpine.tar.gz"

ui_print " "
ui_print "  📦 ПОДГОТОВКА ОКРУЖЕНИЯ HEROKU"
ui_print "  =============================="

install_step "Загрузка ядра Alpine Linux" "curl -L -s -o '$ARCHIVE' '$URL'"
install_step "Распаковка системы" "mkdir -p $ROOTFS && tar -xzf '$ARCHIVE' -C $ROOTFS"
rm "$ARCHIVE"

ui_print "  📥 УСТАНОВКА КОМПОНЕНТОВ:"
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# Устанавливаем готовые бинарные пакеты py3-psutil и зависимости для tgcrypto
install_step "Инсталляция Python 3 & Pip" "chroot $ROOTFS /sbin/apk add --no-cache -q python3 py3-pip"
install_step "Инсталляция Git & Bash" "chroot $ROOTFS /sbin/apk add --no-cache -q git bash curl"
install_step "Инсталляция готового модуля PSUTIL" "chroot $ROOTFS /sbin/apk add --no-cache -q py3-psutil"
install_step "Инсталляция библиотек сборки (GCC)" "chroot $ROOTFS /sbin/apk add --no-cache -q build-base python3-dev musl-dev linux-headers libffi-dev"

ui_print "  ⚙️ НАСТРОЙКА КОНФИГУРАЦИИ:"
install_step "Применение прав доступа" "set_perm_recursive $MODPATH 0 0 0755 0755 && set_perm_recursive $ROOTFS 0 0 0755 0755"

ui_print "  =============================="
ui_print "  ✅ УСТАНОВКА ЗАВЕРШЕНА"
ui_print "  🚀 ПЕРЕЗАГРУЗИТЕ ТЕЛЕФОН"
ui_print "  =============================="

sleep 2
