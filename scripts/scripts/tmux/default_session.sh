#!/bin/bash

SESH="main"

tmux has-session -t $SESH

if [[ $? != 0 ]]; then
	tmux new-session -d -s $SESH -n "main"
	tmux send-keys -t $SESH:main "neofetch" C-m
	tmux select-window -t $SESH:main
fi

tmux attach-session -t $SESH
