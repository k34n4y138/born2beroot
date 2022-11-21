#!/bin/bash

# you should have passed the installation process

apt update
apt upgrade
apt install ssh
sed -i "s/#Port.*/Port 4242/" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config

hst_hld=$(hostname)
hostnamectl set-hostname zmoumen42
sed -i "s/$hst/zmoumen42/" /ets/hosts

apt install sudo
addgroup user42 
adduser zmoumen user42
adduser zmoumen sudo

sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS	30/" /etc/login.defs
sed -i "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS	2/" /etc/login.defs
sed -i "s/PASS_WARN_AGE.*/PASS_WARN_AGE	7/" /etc/login.defs

apt install libpam-pwquality
sed -i "s/pam_pwquality.so.*/pam_pwquality.so	enforce_for_root minlen=10 ucredit=-1 lcredit=-1 dcredit=-1 maxsequence=3 usercheck=1 difok=7/" /etc/pam.d/common-password

apt install ufw
ufw allow 4242
ufw enable

mkdir /var/log/sudo 2> /dev/null

echo "\
#born2beroot requirements
Defaults	badpass_message=\"That's not your password?\"
Defaults	requiretty
Defaults	log_input,log_output
Defaults	iolog_dir=\"/var/log/sudo/%{command}/%{user}/%{seq}\"
Defaults	logfile=\"/var/log/sudo/sudo.log\"
Defaults	passwd_tries=3
Defaults	secure_path=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\"" > /etc/sudoers.d/b2br.sudoers
