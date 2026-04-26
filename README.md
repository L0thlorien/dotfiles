# dotfiles

Personal CachyOS + Hyprland desktop configuration.

## Managed config

- `config/hypr/hyprland.conf` - compositor settings, binds, autostart
- `config/hypr/hyprlock.conf` - lockscreen styling
- `config/hypr/hypridle.conf` - idle and suspend behavior
- `config/hypr/scripts/clipboard-history.sh` - Rofi clipboard picker
- `config/hypr/scripts/screenshot-area.sh` - area screenshot to file + clipboard
- `config/hypr/scripts/screenshot-screen.sh` - full screen screenshot to file + clipboard
- `config/waybar/` - bar layout, styling, power menu
- `config/rofi/config.rasi` - app launcher theme
- `config/alacritty/alacritty.toml` - terminal font configuration
- `config/mako/config` - notifications
- `config/nvim/` - kickstart.nvim-based Neovim config for Python and Go
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
- `gcc`
- `git`
- `make`
- `zellij`
- `neovim`

Desktop integration and utilities:

- `networkmanager`
- `bluez`
- `bluez-utils`
- `brightnessctl`
- `playerctl`
- `mako`
- `wl-clipboard`
- `cliphist`
- `grim`
- `slurp`
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
- `fd`
- `tree-sitter-cli`
- `unzip`
- `xclip`

Language runtimes installed by default:

- `go`
- `python-pytest`

Neovim toolchain installed on first launch via lazy.nvim / Mason:

- kickstart.nvim base config
- `nvim-tree` file explorer (`<leader>e`)
- `basedpyright` + `ruff` for Python
- `gopls` + `goimports`/`gofumpt` for Go
- `nvim-dap`, `nvim-dap-python`, `nvim-dap-go`
- `neotest`, `neotest-python`, `neotest-golang`
- `venv-selector.nvim` for Python virtualenv switching (`<leader>cv`)

Project-level runtime expectations:

- Python projects should provide their own `.venv` / conda env; `python-pytest` is installed by default unless you use `--without-python`
- Go development requires the `go` package if you want to use `gopls`, Delve, formatting, and tests against local projects
- Go debugging additionally requires Delve, which Mason installs on first launch

Intentionally excluded:

- AI coding assistants
- Jupyter / notebook plugins

Optional extras:

- `pinta`
- `amneziavpn-bin`

## Install

```bash
./install.sh
```

To install only Neovim on a machine that already has its own desktop setup:

```bash
./install-nvim.sh
```

That script only touches `~/.config/nvim`, backs up any existing Neovim config first, and leaves Hyprland / Waybar / Rofi / Mako / shell config alone.

To skip Python packages:

```bash
./install.sh --without-python
```

To skip Go packages:

```bash
./install.sh --without-go
```

To skip both:

```bash
./install.sh --without-python --without-go
```

To only sync configs:

```bash
./install.sh --skip-packages
```

Neovim-only variants:

```bash
./install-nvim.sh --without-python
./install-nvim.sh --without-go
./install-nvim.sh --without-python --without-go
./install-nvim.sh --skip-packages
```

Then open Neovim once:

```bash
nvim
```

That first launch bootstraps lazy.nvim and installs the configured plugins and Mason-managed language tools.
The installer brings in the required Neovim-side CLI dependencies such as `tree-sitter-cli` and `xclip` by default.
Go and Python runtime packages are installed by default, and can be excluded with `--without-go` and `--without-python`.

### Neovim setup notes

This Neovim config is based on `kickstart.nvim`, but it is not a stock copy. The base editing, completion, Telescope, LSP, Treesitter, and formatting flow still follow kickstart, while the repo adds a Python/Go-focused layer on top.

Main differences from plain kickstart:

- file explorer via `nvim-tree` instead of relying only on Telescope
- Python workflow centered around `basedpyright`, `ruff`, `venv-selector.nvim`, `nvim-dap-python`, and `neotest-python`
- Go workflow centered around `gopls`, `goimports` / `gofumpt`, `nvim-dap-go`, and `neotest-golang`
- shared debug UI and test workflow already wired in

Specialities of this setup:

- **Venv-aware Python flow:** `<leader>cv` switches the active Python environment. The config tries `VIRTUAL_ENV` / `CONDA_PREFIX`, then `.venv` / `venv`, then falls back to system `python3`.
- **Mason handles editor-side tools:** language servers, formatters, and debug adapters are installed on first launch through Mason rather than being committed into the repo.
- **Project runtime still matters:** Mason installs editor tooling, but your project still needs its own dependencies. For Python that usually means using a project venv. For Go that means having the `go` toolchain installed locally.
- **Ruff-first Python formatting:** Python formatting is set up around `ruff format`, not Black.
- **Go formatting is import-aware:** Go files are formatted with `goimports` and `gofumpt`.
- **No AI / notebook layer:** this config intentionally avoids Copilot-style plugins and Jupyter integrations to keep the setup focused and predictable.

What to expect on first run:

1. `lazy.nvim` installs plugins
2. Mason installs LSP / DAP / formatter tools
3. Treesitter installs parsers
4. After that, Python files should attach `basedpyright` and Go files should attach `gopls`

If something feels "missing", it is usually one of two things:

- the project runtime/dependencies are not installed yet
- the first Neovim bootstrap has not finished yet

## Keybinds

- `Super + Return` - open terminal
- `Super + W` - close focused window
- `Super + E` - open file manager
- `Super + F` - fullscreen focused window
- `Super + R` - app launcher (Rofi)
- `Super + B` - toggle Waybar
- `Super + T` - toggle floating window
- `Super + Shift + L` - lock screen
- `Super + V` - clipboard history via Rofi
- `Super + H/J/K/L` - move focus left/down/up/right
- `Print` - area screenshot to clipboard + file
- `Shift + Print` - full screen screenshot to clipboard + file
- `Alt + Space` - switch keyboard layout (EN/RU)

## Neovim keybinds

- `<leader>e` - toggle nvim-tree file explorer
- `<leader>fe` - reveal current file in nvim-tree
- `<leader>cv` - select Python virtualenv
- `<leader>tn` - run nearest test
- `<leader>tf` - run current test file
- `<leader>td` - debug nearest test
- `<leader>ts` - toggle test summary
- `<leader>to` - open test output
- `<F5>` - start / continue debugger
- `<leader>du` - toggle debugger UI

## Post-install checklist

- reload Hyprland: `hyprctl reload`
- restart the session, or manually restart `hypridle` and `mako`, because a reload alone does not replace already-running daemons
- open a new Alacritty window so font changes apply
- open Neovim once and wait for lazy.nvim / Mason to finish installing plugins and language tools
- if Treesitter parsers fail to build, make sure `tree-sitter-cli` is installed (`sudo pacman -S tree-sitter-cli`)
- test lockscreen with `Super + Shift + L`
- test clipboard history with `Super + V`
- test screenshots with `Print` and `Shift + Print`
- confirm notifications with `notify-send "test" "mako works"`

## Note

Always update BIOS to avoid cuda/nvidia errors (!)
