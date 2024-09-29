#!/bin/bash
randomize_wallpaper () {
	wall_folder='/home/wixaxis/Pictures/nord-papes/'
	wall_filename=$(ls $wall_folder | shuf -n 1)
	wallpaper="${wall_folder}${wall_filename}"
}

set_random_wallpaper () {
	local screen=$1
	randomize_wallpaper
	echo "Setting wallpaper $wallpaper to screen $screen"
	echo $(swww img -o $screen $flags $wallpaper )
}

wallpaper=''
flags='-t random --transition-duration 0.5 --transition-fps 60 --transition-step 255'
screens=( DSI-1 DP-1 DP-2 )
for i in "${screens[@]}" 
do
	set_random_wallpaper "$i"
done
