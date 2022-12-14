#!/bin/bash
# WARNING do not execute this script over ssh in order the process to not get interrupted

vg_oldname=$(vgdisplay | grep "VG Name" | awk '{printf "%s", $3}')
mapper_oldvgname=$(echo $vg_oldname | sed "s/-/--/g")

echo "----setup var lv----"
lvcreate -L 3G -n var $vg_oldname
mkfs -t ext4 /dev/$vg_oldname/var
mkdir /mnt/var && mount /dev/$vg_oldname/var /mnt/var
mv /var/* /mnt/var
mount -o bind /mnt/var /var
umount /mnt/var && rm -r /mnt/var
echo "/dev/$vg_oldname/var	/var	ext4	defaults	0	2" >> /etc/fstab

echo "----setup srv lv-----"
lvcreate -L 3G -n srv $vg_oldname
mkfs -t ext4 /dev/$vg_oldname/srv
mkdir /mnt/srv && mount /dev/$vg_oldname/srv /mnt/srv
mv /srv/* /mnt/srv
mount -o bind /mnt/srv /srv
umount /mnt/srv && rm -r /mnt/srv
echo "/dev/$vg_oldname/srv	/srv	ext4	defaults	0	2" >> /etc/fstab

echo "----setup tmp lv-----"
lvcreate -L 3G -n tmp $vg_oldname
mkfs -t ext4 /dev/$vg_oldname/tmp
mkdir /mnt/tmp && mount /dev/$vg_oldname/tmp /mnt/tmp
mv /tmp/* /mnt/tmp
mount -o bind /mnt/tmp /tmp
umount /mnt/tmp && rm -r /mnt/tmp
echo "/dev/$vg_oldname/tmp	/tmp	ext4	defaults	0	2" >> /etc/fstab

echo "----setup var/log lv----"
lvcreate -L 3G -n var-log $vg_oldname
mkfs -t ext4 /dev/$vg_oldname/var-log
mkdir /mnt/varlog
mount /dev/$vg_oldname/var-log /mnt/varlog
mv /var/log/* /mnt/varlog && mount -o bind /mnt/varlog /var/log
umount /mnt/varlog && rm -r /mnt/varlog
echo "/dev/$vg_oldname/var-log	/var/log	ext4	defaults	0	2" >> /etc/fstab

echo "extend /home / SWAP"

lvextend -L 10G /dev/$vg_oldname/root
resize2fs /dev/$vg_oldname/root

lvextend -L 5G /dev/$vg_oldname/home
resize2fs /dev/$vg_oldname/home

swapoff /dev/$vg_oldname/swap_1
lvextend -L 2G /dev/$vg_oldname/swap_1
mkswap /dev/$vg_oldname/swap_1
swapon /dev/$vg_oldname/swap_1

echo "rename volume group and swap"

lvrename $vg_oldname swap_1 swap
vgrename $vg_oldname LVMGroup
sed -i "s/$vg_oldname/LVMGroup/g" /etc/fstab
sed -i "s/$mapper_oldvgname/LVMGroup/g" /etc/fstab
sed -i "s/swap_1/swap/g" /etc/fstab
sed -i "s/$vg_oldname/LVMGroup/g" /boot/grub/grub.cfg
sed -i "s/swap_1/swap/g" /boot/grub/grub.cfg
sed -i "s/$mapper_oldvgname/LVMGroup/g" /boot/grub/grub.cfg
echo "RESUME=/dev/mapper/LVMGroup-swap" > /etc/initramfs-tools/conf.d/resume
update-initramfs -u
systemctl daemon-reload
mount -a
clear
echo \n\n\n"RESULTS:"
lsblk
echo \n\n\n
reboot