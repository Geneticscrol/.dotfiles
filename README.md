# ✨ Dotfiles / Config Templates

> Clean, portable **XDG-style** configuration templates for a modern Windows-first
> developer setup — shells, editors, prompts, AI tooling, and a status bar.
>
> **These are templates.** Copy what you need, adapt paths, and never commit secrets.

---

<p align="center">
  <img alt="Shell" src="https://img.shields.io/badge/Shell-PowerShell%20%7C%20Nushell%20%7C%20Fish-4B8BBE?style=for-the-badge" />
  <img alt="Editor" src="https://img.shields.io/badge/Editor-Neovim%20(LazyVim)-57A143?style=for-the-badge" />
  <img alt="Prompt" src="https://img.shields.io/badge/Prompt-Starship-C02E5A?style=for-the-badge" />
  <img alt="License" src="https://img.shields.io/badge/Use-Personal%20%26%20public-6c757d?style=for-the-badge" />
</p>

---

## Why this repo exists

Personal `~/.config` trees fill up with **tokens, machine IDs, shell history, and
local paths**. This package is a **sanitized snapshot** of reusable configs only:

| Included | Intentionally excluded |
| --- | --- |
| Shareable settings & themes | API keys, tokens, credentials |
| Plugin / skill definitions | `node_modules`, lockfiles |
| Example OpenCode layout | Live `opencode.json` with secrets |
| Install-oriented docs | Logs, history, UUIDs, session stamps |

Use it as a starting point. Your real secrets stay on **your** machine.

---

## What's inside

```text
public-dotfiles/
├── starship.toml              # Cross-shell prompt (mono-blue)
├── amp/plugins/               # Amp plugin (Orca agent status hook)
├── fish/completions/          # Fish completions (e.g. grok)
├── git/ignore                 # Global-style ignore snippets
├── kilo/                      # Kilo AI CLI config + graphify skill
├── lazygit/                   # LazyGit UI config
├── nushell/                   # Nushell config + env templates
├── nvim/                      # LazyVim-based Neovim setup
├── opencode/                  # OpenCode + oh-my-openagent (no secrets)
├── powershell/                # Profile, Terminal-Icons theme, oh-my-posh theme
└── yasb/                      # Yet Another Status Bar (Windows)
```

### Tool map

| Path | Tool | Notes |
| --- | --- | --- |
| `starship.toml` | [Starship](https://starship.rs) | Multi-line mono-blue prompt; `$fill` right-aligns modules on PowerShell |
| `powershell/` | PowerShell 7+ | Vi-mode PSReadLine, fzf/`fd` fuzzy open, Starship init, Dracula icons |
| `nushell/` | [Nushell](https://www.nushell.sh) | Starter `config.nu` / `env.nu` |
| `fish/completions/` | [Fish](https://fishshell.com) | Completions only (not a full fish config) |
| `nvim/` | Neovim + [LazyVim](https://www.lazyvim.org) | Full starter tree (`init.lua`, plugins, lockfile) |
| `lazygit/config.yml` | [LazyGit](https://github.com/jesseduffield/lazygit) | UI preferences |
| `git/ignore` | Git | Patterns safe for global ignore includes |
| `yasb/` | [YASB](https://github.com/amnweb/yasb) | Windows bar + styles; weather uses env vars |
| `kilo/` | [Kilo](https://kilo.ai) | Permissions, models, graphify skill + `package.json` |
| `opencode/` | [OpenCode](https://opencode.ai) | Plugins, agent routing, MCP **examples** (keys redacted) |
| `amp/plugins/` | Amp | Optional Orca status plugin |

---

## Quick start

### 1. Clone

```bash
git clone <YOUR_REPO_URL> config-templates
cd config-templates
```

### 2. Pick a destination

Configs are laid out for **XDG** / Windows user config:

| OS | Typical config home |
| --- | --- |
| Windows | `%USERPROFILE%\.config` |
| macOS / Linux | `~/.config` |

> **Tip:** Back up your existing files before overwriting anything.

### 3. Copy selectively (recommended)

```powershell
# PowerShell — examples
$src  = ".\config-templates"          # this repo
$dest = "$env:USERPROFILE\.config"

Copy-Item "$src\starship.toml"     $dest -Force
Copy-Item "$src\nvim"              "$dest\nvim" -Recurse -Force
Copy-Item "$src\powershell\*"      "$dest\powershell\" -Recurse -Force
Copy-Item "$src\yasb\*"            "$dest\yasb\" -Force
Copy-Item "$src\lazygit"           "$dest\lazygit" -Recurse -Force
Copy-Item "$src\kilo"              "$dest\kilo" -Recurse -Force
Copy-Item "$src\opencode"          "$dest\opencode" -Recurse -Force
```

```bash
# bash / zsh
SRC=./config-templates
DEST="${XDG_CONFIG_HOME:-$HOME/.config}"

cp "$SRC/starship.toml" "$DEST/"
cp -R "$SRC/nvim" "$DEST/"
cp -R "$SRC/powershell" "$DEST/"   # Windows-oriented; optional on Unix
# …copy only what you use
```

### 4. Wire up PowerShell (Windows)

Point your PowerShell profile at the template profile (or merge the bits you want):

```powershell
# In $PROFILE — load the template profile
. "$env:USERPROFILE\.config\powershell\user_profile.ps1"
```

Suggested modules / tools:

- [Starship](https://starship.rs)
- [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
- [PSFzf](https://github.com/kelleyma49/PSFzf) + [fd](https://github.com/sharkdp/fd) + [fzf](https://github.com/junegunn/fzf)
- Optional: [oh-my-posh](https://ohmyposh.dev) with `powershell/theme.omp.json` (commented out in the profile by default)

### 5. Wire up Starship

```powershell
$env:STARSHIP_CONFIG = "$env:USERPROFILE\.config\starship.toml"
# or permanently:
# setx STARSHIP_CONFIG "%USERPROFILE%\.config\starship.toml"
```

```bash
export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
```

### 6. Neovim (LazyVim)

```bash
# Requires Neovim 0.9+
# First launch will install plugins from the lockfile
nvim
```

See `nvim/README.md` and the [LazyVim docs](https://www.lazyvim.org).

### 7. OpenCode (AI CLI) — **secrets go here**

```powershell
cd $env:USERPROFILE\.config\opencode
Copy-Item opencode.json.example opencode.json
# Edit opencode.json:
#   - set local model names / baseURL for LM Studio
#   - put API keys only in this local file (never commit it)
#   - enable MCP servers you actually use
npm install   # or: bun install
```

The committed file is **`opencode.json.example` only**. Live keys stay out of git
(see this package’s `.gitignore`).

### 8. Kilo plugins

```powershell
cd $env:USERPROFILE\.config\kilo
npm install   # or bun install
```

### 9. YASB (Windows status bar)

1. Install [YASB](https://github.com/amnweb/yasb).
2. Copy `yasb/config.yaml` and `yasb/styles.css`.
3. Weather widget reads **`api_key`** and **`location` from environment variables**
   (`api_key: env`, `location: env` in the template) — set those in your user env,
   not in the YAML, if you want to keep the file shareable.

---

## Design notes

### Prompt (Starship)

- Palette: **mono_blue** (readable on translucent terminals).
- PowerShell cannot use Starship’s `right_format`; this theme uses **`$fill`** so
  language/package modules still hug the right edge of the line.
- Shows OS, host, user, path, git, duration, tool versions, time.

### PowerShell profile

- UTF-8 console
- Vi-mode + history predictions
- `fe` — fuzzy find with `fd` + `fzf`, open in Neovim
- Paths use `$PSScriptRoot` / `$env:USERPROFILE` (no hard-coded usernames)
- Optional oh-my-posh block is commented out (Starship is the default)

### OpenCode + oh-my-openagent

- Example MCP: Playwright, sequential-thinking, Stitch (**disabled**, key placeholder)
- Example local provider: LM Studio-compatible OpenAI API on `127.0.0.1:1234`
- Agent / category model routing in `oh-my-openagent.json` is opinionated — swap models freely

### Security posture

```text
❌ Never commit
   API keys, OAuth tokens, ~/.config/**/credentials*, .env, SSH keys,
   shell history, app logs, machine UUIDs, session stamps

✅ Safe to share
   Themes, keymaps, permission policies, example MCP command shapes,
   plugin package.json manifests, skills docs
```

If a tool forces secrets into a JSON config, keep a **`.example`** in git and
gitignore the live file (as done for OpenCode).

---

## Prerequisites (high level)

| Want | Install |
| --- | --- |
| Prompt | [Starship](https://starship.rs/guide/#%F0%9F%9A%80-installation) + a Nerd Font |
| PowerShell UX | PowerShell 7+, Terminal-Icons, PSFzf, fd, fzf |
| Editor | [Neovim](https://neovim.io/) 0.9+ |
| Git TUI | [LazyGit](https://github.com/jesseduffield/lazygit) |
| Status bar (Win) | [YASB](https://github.com/amnweb/yasb) |
| AI CLIs | OpenCode / Kilo (see their docs) + Node or Bun for plugins |

Package managers that pair well: **Scoop**, **winget**, **Homebrew**, **npm/bun**.

---

## Customization checklist

After copying:

- [ ] Search for `127.0.0.1` / model names and match **your** local stack
- [ ] Replace placeholder API keys; prefer env vars where supported
- [ ] Adjust Starship `username` / `hostname` visibility if you prefer minimal prompts
- [ ] Review Kilo / OpenCode **permission** settings before enabling broad allow rules
- [ ] Run `nvim` once so Lazy.nvim can sync plugins
- [ ] Confirm PowerShell `$PROFILE` sources the profile you expect

---

## Layout vs. your real `~/.config`

This directory is a **standalone template pack**. It is **not** your live config tree.

```text
Your machine                          This repo
─────────────────                     ─────────────────
~/.config/              ← live        public-dotfiles/     ← templates only
  opencode/opencode.json  (secrets)     opencode/*.example
  context7/credentials…   (private)     (not included)
  … history, logs, ids                  (not included)
```

Sync flow if you maintain both:

1. Tweak configs in the real `~/.config` (private).
2. Copy **only** non-secret files into this package when you want to publish updates.
3. Re-scan for usernames, paths, and keys before `git push`.

---

## Contributing / using as a base

- Fork freely for your own public or private dotfiles.
- Prefer small, focused commits per tool.
- When adding a new app config, ask: *Would I paste this in a Discord #config channel?*  
  If not, it does not belong here.

---

## Credits

Configs and layouts inspired by the broader open-source ecosystem:

- [Starship](https://starship.rs) · [LazyVim](https://www.lazyvim.org) · [oh-my-posh](https://ohmyposh.dev)
- [YASB](https://github.com/amnweb/yasb) · [OpenCode](https://opencode.ai) · [Kilo](https://kilo.ai)
- Community plugins, skills (e.g. graphify), and shell tooling authors

---

## Disclaimer

These files are provided **as-is** as personal templates. Review permissions,
network endpoints, and MCP servers before enabling them. You are responsible for
your own API keys, billing, and machine security.

---

<p align="center">
  <sub>Template pack · no secrets · copy → adapt → make it yours</sub>
</p>
