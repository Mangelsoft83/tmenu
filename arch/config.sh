#!/usr/bin/env bash

DISK="/dev/sda"

if [[ "$DISK" =~ nvme|mmcblk|loop ]]; then
  EFI_PART="${DISK}p1"
  ROOT_PART="${DISK}p2"
else
  EFI_PART="${DISK}1"
  ROOT_PART="${DISK}2"
fi

HOSTNAME="arch-thijs"
USERNAME="thijs"
TIMEZONE="Europe/Amsterdam"
LOCALE="en_US.UTF-8"
KEYMAP="us"
