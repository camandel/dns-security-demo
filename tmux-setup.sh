#!/bin/bash

SESSION=dns-security-demo

tmux -2 new-session -d -s $SESSION
tmux new-window -t $SESSION:0

# rebind cmd key
tmux unbind-key C-b
tmux set -g prefix C-a
tmux bind-key C-a send-prefix

# set inactive/active window styles
tmux set -g window-style 'fg=colour250,bg=colour234'
tmux set -g window-active-style 'fg=colour250,bg=black'

# set the pane border colors 
#tmux set -g pane-border-style 'fg=colour250,bg=colour234' 
#tmux set -g pane-border-style 'fg=colour250,bg=black' 
#tmux set -g pane-active-border-style 'fg=colour51,bg=colour236'

tmux split-window -h
tmux select-pane -t 0
tmux send-keys 'docker exec -ti -w /home/app acme-server sh' C-m

tmux split-window -v
tmux select-pane -t 1
tmux resize-pane -y 40%
tmux send-keys 'docker exec -ti -w /root acme-dns sh -' C-m

tmux select-pane -t 2
tmux send-keys 'docker exec -ti -w /root attacker-dns sh -' C-m
tmux split-window -v

tmux select-pane -t 3
tmux resize-pane -y 40%
tmux send-keys 'docker exec -ti -w /root attacker-dns sh' C-m

tmux select-pane -t 0

tmux select-window -t $SESSION:0
tmux -2 attach-session -t $SESSION:0