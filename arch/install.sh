#!/usr/bin/env bash
set -euo pipefail

source ./config.sh

read -rp "This will erase $DISK. Type YES: " confirm
[[ "$confirm" == "YES" ]] || exit 1

echo "timedatectl"
timedatectl set-ntp true

echo "sgdisk"
sgdisk --zap-all "$DISK"
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:EFI "$DISK"
sgdisk -n 2:0:0   -t 2:8300 -c 2:ROOT "$DISK"

partprobe "$DISK"
udevadm settle
sleep 2

mkfs.fat -F32 "$EFI_PART"
mkfs.ext4 -F "$ROOT_PART"

mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

echo "pacstrap"
pacstrap -K /mnt $(grep -vE '^\s*#|^\s*$' packages.txt)

echo "genfstav"
genfstab -U /mnt >> /mnt/etc/fstab

cp config.sh chroot.sh /mnt/root/
arch-chroot /mnt /root/chroot.sh

umount -R /mnt

echo "Install done. Reboot when ready."
