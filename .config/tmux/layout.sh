#!/bin/bash

tmux attach-session

tmux split-window -v  # Horizontal split
tmux resize-pane -t 0 -y 36
tmux split-window -h  # Vertical split in the first pane
tmux select-pane -t 0
tmux split-window -h  # Vertical split in the second pane
tmux select-pane -t 0

tmux send-keys -t 0 ' clear' C-m
tmux send-keys -t 0 ' sudo btop' C-m

tmux send-keys -t 1 ' clear' C-m
tmux send-keys -t 1 ' fastfetch' C-m

tmux send-keys -t 2 ' clear' C-m
tmux send-keys -t 2 ' sudo nethogs -a' C-m

tmux send-keys -t 3 ' clear' C-m
tmux send-keys -t 3 ' ping -c 3 www.speedtest.net' C-m
