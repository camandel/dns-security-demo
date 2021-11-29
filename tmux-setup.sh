#!/bin/bash

SESSION=dns-security-demo

tmux -2 new-session -d -s $SESSION
tmux new-window -t $SESSION:0

tmux split-window -h
tmux select-pane -t 0
tmux send-keys 'docker exec -ti acme-server sh' C-m

tmux split-window -v
tmux select-pane -t 1
tmux resize-pane -y 50%
tmux send-keys 'docker exec -ti acme-dns sh' C-m

tmux select-pane -t 2
tmux send-keys 'docker exec -ti attacker-dns sh' C-m

tmux select-window -t $SESSION:0
tmux -2 attach-session -t $SESSION:0
