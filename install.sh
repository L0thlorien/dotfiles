#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT="$SCRIPT_DIR/config"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

CORE_PACKAGES=(
  hyprland
  hyprlock
  hypridle
  waybar
  wlogout
  alacritty
  dolphin
  fish
  zellij
  otf-hermit-nerd
  papirus-icon-theme
  rofi
  networkmanager
  bluez
  bluez-utils
  brightnessctl
  playerctl
  mako
  wl-clipboard
  cliphist
  pipewire
  wireplumber
  bluetui
  impala
  wiremix
  lazygit
  btop
  fastfetch
  obsidian
  evince
  telegram-desktop
)

OPTIONAL_REPO_PACKAGES=()

OPTIONAL_AUR_PACKAGES=(
  pinta
  amneziavpn-bin
)

usage() {
  cat <<'EOF'
Usage: ./install.sh [--skip-packages]

Options:
  --skip-packages  Do not install packages with pacman.
  -h, --help       Show this help.

The script:
  1. Installs required CachyOS/Arch packages with pacman
  2. Installs optional AUR packages if yay/paru is available
  3. Backs up existing managed config files
  4. Copies repo config files into ~/.config
  5. Sets up lock, idle, notifications, clipboard, terminal, and launcher configs
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

  require_file "$source"
  mkdir -p "$(dirname "$target")"

  if [[ -f "$target" ]]; then
    backup_file "$target"
    log "Overwriting existing file: $target"
  fi

  install -m 0644 "$source" "$target"
  log "Installed $(basename "$source") -> $target"
}

install_packages() {
  local optional_repo_to_install=()
  local optional_aur_to_install=()
  local aur_helper=""
  local pkg

  command -v pacman >/dev/null 2>&1 || die "pacman is required for package installation. Re-run with --skip-packages to only copy configs."

  for pkg in "${OPTIONAL_REPO_PACKAGES[@]}"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
      optional_repo_to_install+=("$pkg")
    else
      warn "Optional package not found in repos, skipping: $pkg"
    fi
  done

  log "Installing required packages with pacman"
  sudo pacman -S --needed "${CORE_PACKAGES[@]}" "${optional_repo_to_install[@]}"

  if command -v paru >/dev/null 2>&1; then
    aur_helper="paru"
  elif command -v yay >/dev/null 2>&1; then
    aur_helper="yay"
  fi

  if [[ -n "$aur_helper" ]]; then
    for pkg in "${OPTIONAL_AUR_PACKAGES[@]}"; do
      optional_aur_to_install+=("$pkg")
    done

    if [[ ${#optional_aur_to_install[@]} -gt 0 ]]; then
      log "Installing optional AUR packages with $aur_helper"
      "$aur_helper" -S --needed "${optional_aur_to_install[@]}"
    fi
  else
    warn "No AUR helper found (paru/yay). Skipping optional AUR packages: ${OPTIONAL_AUR_PACKAGES[*]}"
  fi
}

main() {
  local skip_packages=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-packages)
        skip_packages=true
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
  require_file "$CONFIG_ROOT/hypr/hyprlock.conf"
  require_file "$CONFIG_ROOT/hypr/hypridle.conf"
  require_file "$CONFIG_ROOT/hypr/scripts/clipboard-history.sh"
  require_file "$CONFIG_ROOT/alacritty/alacritty.toml"
  require_file "$CONFIG_ROOT/fish/config.fish"
  require_file "$CONFIG_ROOT/zellij/config.kdl"
  require_file "$CONFIG_ROOT/waybar/config.jsonc"
  require_file "$CONFIG_ROOT/waybar/style.css"
  require_file "$CONFIG_ROOT/waybar/power_menu.xml"
  require_file "$CONFIG_ROOT/autostart/nm-applet.desktop"
  require_file "$CONFIG_ROOT/autostart/blueman.desktop"
  require_file "$CONFIG_ROOT/mako/config"
  require_file "$CONFIG_ROOT/rofi/config.rasi"

  if [[ "$skip_packages" == "false" ]]; then
    install_packages
  else
    log "Skipping package installation"
  fi

  copy_file "$CONFIG_ROOT/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
  copy_file "$CONFIG_ROOT/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
  copy_file "$CONFIG_ROOT/hypr/hypridle.conf" "$HOME/.config/hypr/hypridle.conf"
  copy_file "$CONFIG_ROOT/hypr/scripts/clipboard-history.sh" "$HOME/.config/hypr/scripts/clipboard-history.sh"
  copy_file "$CONFIG_ROOT/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
  copy_file "$CONFIG_ROOT/fish/config.fish" "$HOME/.config/fish/config.fish"
  copy_file "$CONFIG_ROOT/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
  copy_file "$CONFIG_ROOT/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
  copy_file "$CONFIG_ROOT/waybar/style.css" "$HOME/.config/waybar/style.css"
  copy_file "$CONFIG_ROOT/waybar/power_menu.xml" "$HOME/.config/waybar/power_menu.xml"
  copy_file "$CONFIG_ROOT/autostart/nm-applet.desktop" "$HOME/.config/autostart/nm-applet.desktop"
  copy_file "$CONFIG_ROOT/autostart/blueman.desktop" "$HOME/.config/autostart/blueman.desktop"
  copy_file "$CONFIG_ROOT/mako/config" "$HOME/.config/mako/config"
  copy_file "$CONFIG_ROOT/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"

  log "Done. Reload Hyprland, then restart or log into a new session for hypridle and mako changes to fully apply. Open a new terminal window for shell/font changes."
}

main "$@"
