#!/bin/bash

notify-send "which ruby $(which ruby)"

if [ "$#" -eq 0 ] ; then
	echo "region"
	echo "screen"
	echo "window"
	echo "region & save"
	echo "screen & save"
	echo "window & save"
elif [ "$1" == "init" ] ; then rofi -show hypershot -modes "hypershot:/home/wixaxis/scripts/rofi-hyprshot.sh"
elif [ "$1" == "region" ] ; then killall rofi && hyprshot -m region --clipboard-only
elif [ "$1" == "screen" ] ; then killall rofi && hyprshot -m output --clipboard-only
elif [ "$1" == "window" ] ; then killall rofi && hyprshot -m window --clipboard-only
elif [ "$1" == "region & save" ] ; then killall rofi && hyprshot -m region -o '/home/wixaxis/Pictures/screenshots/'
elif [ "$1" == "screen & save" ] ; then killall rofi && hyprshot -m output -o '/home/wixaxis/Pictures/screenshots/'
elif [ "$1" == "window & save" ] ; then killall rofi && hyprshot -m window -o '/home/wixaxis/Pictures/screenshots/'
else echo Error parsing option $1
fi
