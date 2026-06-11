#!/usr/bin/env bash
set -euo pipefail

source /root/config.sh

ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

echo "$HOSTNAME" > /etc/hostname

cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOF

systemctl enable NetworkManager

useradd -m -G wheel -s /bin/bash "$USERNAME"
passwd "$USERNAME"

echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

mkdir -p /boot/EFI/BOOT

cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/
cp /usr/share/limine/limine.conf /boot/

ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")

mkdir -p /boot/EFI/BOOT

cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI

cat > /boot/limine.conf <<EOF
TIMEOUT=5

:Arch Linux
    PROTOCOL=linux
    KERNEL_PATH=boot():/vmlinuz-linux
    CMDLINE=root=UUID=$ROOT_UUID rw
    MODULE_PATH=boot():/intel-ucode.img
    MODULE_PATH=boot():/amd-ucode.img
    MODULE_PATH=boot():/initramfs-linux.img
EOF

efibootmgr \
  --create \
  --disk "$DISK" \
  --part 1 \
  --label "Limine" \
  --loader '\EFI\BOOT\BOOTX64.EFI'
# cat > /boot/loader/loader.conf <<EOF
# default arch.conf
# timeout 3
# console-mode max
# editor no
# EOF
#
# ROOT_UUID=$(blkud -s UUID -o value "$ROOT_PART")
#
# cat > /boot/loader/entries/arch.conf <<EOF
# title Arch Linux
# linux /vmlinuz-linux
# initrd /intel-ucode.img
# initrd /amd-ucode.img
# initrd /initramfs-linux.img
# options root=UUID=$ROOT_UUID rw
# EOF
