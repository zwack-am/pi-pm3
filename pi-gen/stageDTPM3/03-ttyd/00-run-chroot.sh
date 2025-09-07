#!/bin/bash -e

cd /usr/local/bin

for i in aarch64 arm armhf
do
  wget https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${i} 
done
  
case `uname -m` in
  "armv7l") model=armhf ;;
  "aarch64") model=aarch64 ;;
  *) model=arm ;;
esac

cp  ttyd.${model}  /usr/local/bin/ttyd
chown root:root /usr/local/bin/ttyd
chmod a+x /usr/local/bin/ttyd
USER_UID=$(id -u dt)

cat > /etc/systemd/system/ttyd-bash.service << EOF
[Unit]
Description=Web Terminal Service running Bash
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
User=dt
WorkingDirectory=/home/dt
ExecStart=/usr/local/bin/ttyd -p 8000 -W -u $USER_UID -m 1 -c dt:proxmark3 /usr/bin/bash
Restart=always
Type=simple
RestartSec=1

EOF

cat > /etc/systemd/system/ttyd-pm3.service << EOF
[Unit]
Description=Web Terminal Service for PM3
After=network.target
ConditionFileIsExecutable=/usr/local/bin/pm3

[Install]
WantedBy=multi-user.target

[Service]
User=dt
WorkingDirectory=/home/dt
ExecStart=/usr/local/bin/ttyd -p 8080 -W -u $USER_UID -m 1 /usr/local/bin/pm3
Restart=always
Type=simple
RestartSec=1

EOF

chmod 755 /etc/systemd/system/ttyd*.service 
chown root:root /etc/systemd/system/ttyd*.service

if [ ! -L /etc/systemd/system/multi-user.target.wants/ttyd-bash.service ]
then
  ln -s /etc/systemd/system/ttyd-bash.service /etc/systemd/system/multi-user.target.wants
fi

if [ ! -L /etc/systemd/system/multi-user.target.wants/ttyd-pm3.service ]
then
  ln -s /etc/systemd/system/ttyd-pm3.service /etc/systemd/system/multi-user.target.wants
fi

cd /home/dt/proxmark3
make install
