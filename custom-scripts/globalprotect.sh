#!/bin/sh

# Author : Hanzala Sohrab

#echo "What is your name?"
#read PERSON
#echo "Hello, $PERSON"

cd /opt

apt remove --purge globalprotect -y

#dpkg -i GlobalProtect_deb-5.2.1.0-7.deb
dpkg -i GlobalProtect_UI_deb-5.2.1.0-7.deb

#globalprotect connect -p trail.infoedge.com
