#!/bin/bash

echo "install bonus's additional service of choice: gdbserver"

apt install gdbserver gdb gcc -y

echo "\
[Unit]
Description=GDB remote debugging server

[Service]
ExecStart=/usr/bin/gdbserver --multi 0.0.0.0:7442
Restart=always

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/gdbserver.service
systemctl ebable gdbserver.service
systemctl start gdbserver.service

ufw allow 7442
ufw enable

clear
ufw status 
echo "\
Bonus service has been set
bonus service is GDB server and is listening on port 7442
Auf Wiedersehen!
"