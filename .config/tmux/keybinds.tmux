bind '%' split-window -c '#{pane_current_path}' -h
bind '"' split-window -c '#{pane_current_path}'
bind c new-window -c '#{pane_current_path}'
bind-key x kill-pane
bind-key & kill-window

bind-key "k" display-popup -E -w 40% "sesh connect \"$(
  sesh list -i | gum filter --limit 1 --fuzzy --no-sort --placeholder 'Pick a sesh' --prompt='⚡'
)\""
