#!/bin/bash

notify-send -t 150000 -u critical "Switching to $@, please wait..." &&

envy=$(sudo envycontrol -s $@)
if [[ "$envy" == *"Operation completed successfully"* ]]; then
  choice=$(notify-send -u critical -w "GPU set to $@. Do you want to reboot?" -A reboot='Reboot now' -A cancel='Reboot later')

  if [[ "$choice" == "reboot" ]]; then
    notify-send -u critical "Rebooting, please wait..."
    reboot
  else
    notify-send -u critical "Aborting... \nPlease reboot as soon as possible!"
  fi
else
  notify-send -u critical "$envy"
  notify-send -u critical "Couldn't set GPU, Aborting..."
fi 



# envy=$(sudo envycontrol -s $@)
# if [ ! -z "$envy" ]; then
#   # notify-send -u low "envycontrol returned $envy"
#
#   choice=$(notify-send -u critical -w "GPU set to $@. Do you want to reboot?" -A reboot='Reboot now to use set GPU' -A cancel='I will do it later')
#
#   notify-send "chosen $choice"
#
# else
#   notify-send -u critical "Couldn't set GPU, Aborting..."
# fi 
