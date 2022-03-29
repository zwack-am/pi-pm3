#!/bin/bash -e

su - dt
git clone https://github.com/RfidResearchGroup/proxmark3 
cd proxmark3
echo PLATFORM=PM3GENERIC > Makefile.platform 
#make clean && make -j
exit
#make install

