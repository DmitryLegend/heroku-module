#!/system/bin/sh

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
ui_print "  📦 ФИНАЛЬНАЯ НАСТРОЙКА HEROKU"
ui_print "  =============================="

install_step "Загрузка Alpine" "curl -L -s -o '$ARCHIVE' '$URL'"
install_step "Распаковка" "mkdir -p $ROOTFS && tar -xzf '$ARCHIVE' -C $ROOTFS"
rm "$ARCHIVE"

ui_print "  📥 УСТАНОВКА БИНАРНЫХ ПАКЕТОВ:"
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

# [span_7](start_span)Ключевое исправление: ставим скомпилированный psutil и инструменты сборки для tgcrypto[span_7](end_span)
install_step "Python 3 & Pip" "chroot $ROOTFS /sbin/apk add --no-cache -q python3 py3-pip"
install_step "Git & Инструменты" "chroot $ROOTFS /sbin/apk add --no-cache -q git bash curl"
install_step "Бинарный PSUTIL" "chroot $ROOTFS /sbin/apk add --no-cache -q py3-psutil"
[span_8](start_span)install_step "Компилятор GCC (на всякий случай)" "chroot $ROOTFS /sbin/apk add --no-cache -q build-base python3-dev musl-dev linux-headers libffi-dev"[span_8](end_span)

install_step "Настройка прав" "set_perm_recursive $MODPATH 0 0 0755 0755 && set_perm_recursive $ROOTFS 0 0 0755 0755"

ui_print "  =============================="
ui_print "  ✅ ГОТОВО. ПЕРЕЗАГРУЗИСЬ!"
ui_p
rint " "
