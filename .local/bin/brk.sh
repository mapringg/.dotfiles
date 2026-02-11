#!/usr/bin/env bash
fd --hidden --type l \
  --exclude node_modules \
  --exclude .git \
  --exclude .cache \
  --exclude Library \
  . ~ \
  --exec sh -c 'test ! -e "$1" && echo "$1"' _ {}
