#!/bin/bash -e

#cd /usr/local/bin
wget https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.aarch64
wget https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.armhf
wget https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.arm


cat << EOF > /usr/local/bin/ttyd
#! /bin/bash
/usr/local/bin/ttyd.`/usr/bin/uname -m` $@
EOF

chown root:root /usr/local/bin/ttyd*
chmod a+x /usr/local/bin/ttyd*

