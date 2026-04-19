# dotfiles

Personal CachyOS + Hyprland desktop configuration.

## Managed config

- `config/hypr/hyprland.conf` - compositor settings, binds, autostart
- `config/hypr/hyprlock.conf` - lockscreen styling
- `config/hypr/hypridle.conf` - idle and suspend behavior
- `config/hypr/scripts/clipboard-history.sh` - Rofi clipboard picker
- `config/waybar/` - bar layout, styling, power menu
- `config/rofi/config.rasi` - app launcher theme
- `config/alacritty/alacritty.toml` - terminal font configuration
- `config/mako/config` - notifications
- `config/fish/config.fish` - shell startup
- `config/zellij/config.kdl` - terminal multiplexer keybinds
- `config/autostart/` - applet autostart overrides

## Packages expected by this setup

Core desktop tools:

- `hyprland`
- `hyprlock`
- `hypridle`
- `waybar`
- `wlogout`
- `rofi`
- `alacritty`
- `dolphin`
- `fish`
- `zellij`

Desktop integration and utilities:

- `networkmanager`
- `bluez`
- `bluez-utils`
- `brightnessctl`
- `playerctl`
- `mako`
- `wl-clipboard`
- `cliphist`
- `pipewire`
- `wireplumber`
- `bluetui`
- `impala`
- `wiremix`
- `telegram-desktop`
- `evince`
- `obsidian`
- `fastfetch`
- `btop`
- `lazygit`
- `otf-hermit-nerd`
- `papirus-icon-theme`

Optional extras:

- `pinta`
- `amneziavpn-bin`

## Install

```bash
./install.sh
```

To only sync configs:

```bash
./install.sh --skip-packages
```

## Keybinds

- `Super + Q` - open terminal
- `Super + E` - open file manager
- `Super + R` - app launcher (Rofi)
- `Super + L` - lock screen
- `Super + V` - clipboard history via Rofi
- `Super + Shift + V` - toggle floating window
- `Alt + Space` - switch keyboard layout (EN/RU)

## Post-install checklist

- reload Hyprland: `hyprctl reload`
- restart the session, or manually restart `hypridle` and `mako`, because a reload alone does not replace already-running daemons
- open a new Alacritty window so font changes apply
- test lockscreen with `Super + L`
- test clipboard history with `Super + V`
- confirm notifications with `notify-send "test" "mako works"`
