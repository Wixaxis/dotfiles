#!/bin/bash

if [ "$#" -eq 0 ] ; then
	echo "suspend"
	echo "hibernate"
	echo "reboot"
	echo "poweroff"
elif [ "$1" == "init" ] ; then rofi -show power -modes "power:/home/wixaxis/scripts/powermenu.sh"
elif [ "$1" == "suspend" ] ; then systemctl suspend
elif [ "$1" == "hibernate" ] ; then systemctl hibernate
elif [ "$1" == "reboot" ] ; then systemctl reboot
elif [ "$1" == "poweroff" ] ; then systemctl poweroff
else echo Error parsing option $1
fi
