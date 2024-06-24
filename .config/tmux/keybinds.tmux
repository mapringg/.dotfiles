set -g prefix C-a

bind '%' split-window -c '#{pane_current_path}' -h
bind '"' split-window -c '#{pane_current_path}'
bind c new-window -c '#{pane_current_path}'

bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt (cmd+w)

bind-key "k" display-popup -E -w 40% "sesh connect \"$(
  sesh list -i | gum filter --limit 1 --fuzzy --no-sort --placeholder 'Pick a sesh' --prompt='⚡'
)\""
