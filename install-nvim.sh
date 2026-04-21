#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$SCRIPT_DIR/config/nvim"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

CORE_PACKAGES=(
  gcc
  git
  make
  neovim
  tree-sitter-cli
  unzip
  xclip
)

GO_PACKAGES=(
  go
)

PYTHON_PACKAGES=(
  python-pytest
)

usage() {
  cat <<'EOF'
Usage: ./install-nvim.sh [--skip-packages] [--without-python] [--without-go]

Options:
  --skip-packages  Do not install packages with pacman.
  --without-python Do not install Python runtime packages.
  --without-go     Do not install Go runtime packages.
  -h, --help       Show this help.

The script:
  1. Installs Neovim prerequisites with pacman
  2. Optionally skips Python or Go runtime packages
  3. Backs up any existing ~/.config/nvim directory
  4. Replaces ~/.config/nvim with this repo's Neovim config only

This script does not touch Hyprland, Waybar, Rofi, Mako, shell config, or any
other desktop settings.
EOF
}

log() {
  printf '[dotfiles:nvim] %s\n' "$1"
}

warn() {
  printf '[dotfiles:nvim][warn] %s\n' "$1" >&2
}

die() {
  printf '[dotfiles:nvim][error] %s\n' "$1" >&2
  exit 1
}

require_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || die "Required directory not found: $dir"
}

install_packages() {
  local with_python="$1"
  local with_go="$2"
  local packages=("${CORE_PACKAGES[@]}")
  local pkg

  command -v pacman >/dev/null 2>&1 || die 'pacman is required for package installation. Re-run with --skip-packages to only copy the config.'

  if [[ "$with_go" == "true" ]]; then
    packages+=("${GO_PACKAGES[@]}")
  else
    log 'Skipping Go runtime packages'
  fi

  if [[ "$with_python" == "true" ]]; then
    packages+=("${PYTHON_PACKAGES[@]}")
  else
    log 'Skipping Python runtime packages'
  fi

  for pkg in "${packages[@]}"; do
    pacman -Si "$pkg" >/dev/null 2>&1 || die "Package not found in repos: $pkg"
  done

  log 'Installing Neovim packages with pacman'
  sudo pacman -S --needed "${packages[@]}"
}

backup_existing_nvim() {
  local target="$HOME/.config/nvim"

  if [[ -e "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp -a "$target" "$BACKUP_DIR/"
    log "Backed up existing nvim config to $BACKUP_DIR"
  fi
}

install_nvim_config() {
  local source="$CONFIG_ROOT"
  local target="$HOME/.config/nvim"

  require_dir "$source"
  mkdir -p "$HOME/.config"

  backup_existing_nvim
  rm -rf "$target"
  cp -a "$source" "$target"
  log "Installed Neovim config to $target"
}

main() {
  local skip_packages=false
  local with_python=true
  local with_go=true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-packages)
        skip_packages=true
        ;;
      --without-python)
        with_python=false
        ;;
      --without-go)
        with_go=false
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
    shift
  done

  if [[ "$skip_packages" == "false" ]]; then
    install_packages "$with_python" "$with_go"
  else
    log 'Skipping package installation'
  fi

  install_nvim_config

  log 'Done. Start Neovim once so lazy.nvim, Mason, and Treesitter can finish bootstrapping the editor tools.'
}

main "$@"
