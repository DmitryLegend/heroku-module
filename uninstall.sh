#!/system/bin/sh

# Пути к папкам, которые нужно удалить
ROOTFS="/data/local/linux_bot"

# 1. Размонтируем всё, что было примонтировано, чтобы удаление прошло чисто
umount -l $ROOTFS/dev 2>/dev/null
umount -l $ROOTFS/proc 2>/dev/null
umount -l $ROOTFS/sys 2>/dev/null
umount -l $ROOTFS/sdcard 2>/dev/null

# 2. Полностью удаляем папку с Linux и юзерботом
if [ -d "$ROOTFS" ]; then
    rm -rf "$ROOTFS"
fi

# Сообщение в лог (опционально)
# Логи удаления Magisk хранит во внутренних па
пках
