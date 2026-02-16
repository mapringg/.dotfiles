bindkey -e

if command -v tms >/dev/null 2>&1; then
  bindkey -s '^g' $'tms\n'
fi
