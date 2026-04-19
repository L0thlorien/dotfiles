#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$SCRIPT_DIR/config"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

CORE_PACKAGES=(
  hyprland
  waybar
  blueman
  networkmanager
  network-manager-applet
  pavucontrol
  wlogout
  alacritty
  dolphin
  pipewire
  wireplumber
)

OPTIONAL_PACKAGES=(
  hyprlauncher
)

usage() {
  cat <<'EOF'
Usage: ./install.sh [--skip-packages] [--force]

Options:
  --skip-packages  Do not install packages with pacman.
  --force          Overwrite existing target files without creating per-file prompts.
  -h, --help       Show this help.

The script:
  1. Installs required CachyOS/Arch packages with pacman
  2. Backs up existing Hyprland/Waybar config files
  3. Copies repo config files into ~/.config
EOF
}

log() {
  printf '[dotfiles] %s\n' "$1"
}

warn() {
  printf '[dotfiles][warn] %s\n' "$1" >&2
}

die() {
  printf '[dotfiles][error] %s\n' "$1" >&2
  exit 1
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] || die "Required file not found: $file"
}

backup_file() {
  local target="$1"
  if [[ -f "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp -a "$target" "$BACKUP_DIR/"
    log "Backed up $(basename "$target") to $BACKUP_DIR"
  fi
}

copy_file() {
  local source="$1"
  local target="$2"
  local force="$3"

  require_file "$source"
  mkdir -p "$(dirname "$target")"

  if [[ -f "$target" ]]; then
    backup_file "$target"
    if [[ "$force" != "true" ]]; then
      log "Overwriting existing file: $target"
    fi
  fi

  install -m 0644 "$source" "$target"
  log "Installed $(basename "$source") -> $target"
}

install_packages() {
  local optional_to_install=()
  local pkg

  command -v pacman >/dev/null 2>&1 || die "pacman is required for package installation. Re-run with --skip-packages to only copy configs."

  for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
      optional_to_install+=("$pkg")
    else
      warn "Optional package not found in repos, skipping: $pkg"
    fi
  done

  log "Installing required packages with pacman"
  sudo pacman -S --needed "${CORE_PACKAGES[@]}" "${optional_to_install[@]}"
}

main() {
  local skip_packages=false
  local force=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-packages)
        skip_packages=true
        ;;
      --force)
        force=true
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

  require_file "$CONFIG_ROOT/hypr/hyprland.conf"
  require_file "$CONFIG_ROOT/waybar/config.jsonc"
  require_file "$CONFIG_ROOT/waybar/style.css"
  require_file "$CONFIG_ROOT/waybar/power_menu.xml"

  if [[ "$skip_packages" == "false" ]]; then
    install_packages
  else
    log "Skipping package installation"
  fi

  copy_file "$CONFIG_ROOT/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf" "$force"
  copy_file "$CONFIG_ROOT/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc" "$force"
  copy_file "$CONFIG_ROOT/waybar/style.css" "$HOME/.config/waybar/style.css" "$force"
  copy_file "$CONFIG_ROOT/waybar/power_menu.xml" "$HOME/.config/waybar/power_menu.xml" "$force"

  log "Done. Restart Hyprland and Waybar to apply changes."
}

main "$@"
