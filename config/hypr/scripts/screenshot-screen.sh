#!/usr/bin/env bash

set -euo pipefail

mkdir -p "$HOME/Pictures/Screenshots"
file="$HOME/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S_%N')_screen.png"

grim - | tee "$file" | wl-copy

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Screenshot saved" "$file"
fi
