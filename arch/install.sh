#! /bin/bash


if [ $# -ne 1 ]
then
    echo usage $0 hostname
    exit 1
fi

HOSTNAME=$1

echo "arch install script"

# create a linux partition taking the entore disk
echo 'type=83' | sudo sfdisk /dev/sda

# format the partition as ext4
mkfs.ext4 /dev/sda1

# mount the new partition
mount /dev/root_partition /mnt

# install basic packages
pacstrap /mnt base linux linux-firmware vim

# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# chroot to new system
arch-chroot /mnt /bin/bash -- << INSTALL_DOC

# set timezone to Pacific
ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime

# generate /etc/adjtime
hwclock --systohc

# Localization
sed -i "s/#en_US.UTF-8/en_US.UTF-8/" -i /etc/locale.gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# setup networking
echo $HOSTNAME > /etc/hostname
echo 127.0.0.1  localhost > /etc/hosts
echo ::.1  localhost >> /etc/hosts
echo 127.0.1.1 $HOSTNAME > /etc/hosts

# set password
passwd

# setup bootloader
pacman -Sy grub --noconfirm
grub-install --target=i386-pc /dev/sda

INSTALL_DOC


