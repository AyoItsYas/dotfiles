#!/bin/bash

SESSION_NAME=main

tmux new-session -A -t $SESSION_NAME

tmux split-window -v # horizontal split
tmux resize-pane -t 0 -y 45
tmux split-window -h # vertical split in the first pane
tmux select-pane -t 0
tmux split-window -h # vertical split in the second pane
tmux select-pane -t 0

#tmux send-keys -t 0 'clear' C-m
tmux send-keys -t 0 'sudo btop' C-m

#tmux send-keys -t 1 'clear' C-m
#tmux send-keys -t 1 'fastfetch' C-m

#tmux send-keys -t 2 'sleep 1 && clear' C-m
#tmux send-keys -t 2 'sudo nethogs wlan0 enp0s31f6 -b -v 3 -C' C-m

#tmux send-keys -t 3 'sleep 1 && clear' C-m
#tmux send-keys -t 3 'ping -c 3 www.speedtest.net' C-m
