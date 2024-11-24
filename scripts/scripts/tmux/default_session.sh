#!/bin/bash

SESH="main"

tmux has-session -t $SESH

if [[ $? != 0 ]]; then
	tmux new-session -d -s $SESH:1 -n "main_terminal"
	tmux send-keys -t $SESH:1 "neofetch" C-m

	tmux new-window -t $SESH:2 -n "files"
	tmux send-keys -t $SESH:2 "cd ~ && yazi" C-m
	tmux send-keys -t $SESH:2 "yazi" C-m

	tmux new-window -t $SESH:3 -n "auxiliary_terminal"
	tmux send-keys -t $SESH:3 "neofetch" C-m

	tmux new-window -t $SESH:4 -n "updates"
	tmux send-keys -t $SESH:4 "just update" C-m

	tmux new-window -t $SESH:5 -n "ollama"
	tmux send-keys -t $SESH:5 "sleep 5 && ollama run llama3.2" C-m
	tmux split-window -h -t $SESH:5
	tmux send-keys -t $SESH:5.2 "ollama serve" C-m

	tmux select-window -t $SESH:1
fi

tmux attach-session -t $SESH
