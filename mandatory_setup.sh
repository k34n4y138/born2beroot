#!/bin/bash

# you should have passed the installation process

apt update
apt upgrade

addgroup user42
adduser zmoumen user42

apt install ssh -y

sed -i "s/#Port.*/Port 4242/" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
systemctl restart sshd.service

hst_hld=$(hostname)
hostnamectl set-hostname zmoumen42
sed -i "s/$hst_hld/zmoumen42/" /etc/hosts


sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS	30/" /etc/login.defs
sed -i "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS	2/" /etc/login.defs
sed -i "s/PASS_WARN_AGE.*/PASS_WARN_AGE	7/" /etc/login.defs

apt install libpam-pwquality -y
sed -i "s/pam_pwquality.so.*/pam_pwquality.so	enforce_for_root retry=3 minlen=10 ucredit=-1 lcredit=-1 dcredit=-1 maxsequence=3 usercheck=1 difok=7/" /etc/pam.d/common-password


echo "138R@@7pa55\n138R@@7pa55" | passwd root
echo "Zm00HJ^@&ihsg\nZm00HJ^@&ihsg" | passwd zmoumen

apt install ufw -y
ufw allow 4242
ufw enable

apt install sudo -y

mkdir /var/log/sudo 2> /dev/null
touch /var/log/sudo/sudo.log

echo "\
#born2beroot requirements
Defaults	badpass_message=\"That's not your password?\"
Defaults	requiretty
Defaults	log_input,log_output
Defaults	iolog_dir=\"/var/log/sudo/%{command}/%{user}/%{seq}\"
Defaults	logfile=\"/var/log/sudo/sudo.log\"
Defaults	passwd_tries=3
Defaults	secure_path=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\"" >> /etc/sudoers

adduser zmoumen sudo
sudo echo hello world

wget https://raw.githubusercontent.com/k34n4y138/born2beroot/master/monitoring.sh -O /monitoring.sh
chmod +x /monitoring.sh
echo "*/10 * * * * /monitoring.sh" | crontab
systemctl reload cron.service

clear

lsblk

echo "------------------"

ufw status

echo "--------------------"

crontab -l

echo "--------------------"

echo "new root password 138R@@7pa55"
echo "new zmoumen password Zm00HJ^@&ihsg"