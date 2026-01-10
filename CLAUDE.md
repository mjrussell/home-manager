# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix home-manager configuration for managing dotfiles and packages across multiple macOS machines.

## Commands

```bash
# Apply configuration (replace PROFILE with: work, personal, personal-m1, or macmini)
home-manager switch --flake .#PROFILE

# Build without activating
home-manager build --flake .#PROFILE

# Format nix files
nixfmt-classic *.nix profiles/*.nix
```

## Architecture

**flake.nix** - Entry point defining four home configurations:
- `work` - Work M1 Mac (aarch64-darwin, username: matt)
- `personal` - Personal Intel Mac (x86_64-darwin, username: matthewrussell)
- `personal-m1` - Personal M1 Mac (aarch64-darwin, username: matthewrussell)
- `macmini` - Mac Mini for ClawdBot (aarch64-darwin, username: matt)

**home.nix** - Shared base configuration for all machines. Contains:
- Common packages (fd, ripgrep, jq, gh, etc.)
- Zsh configuration with oh-my-zsh and plugins
- Git config with 1Password SSH signing and conditional email by directory
- Starship prompt, fzf, bat, direnv, autojump
- 1Password SSH agent integration

**profiles/*.nix** - Machine-specific overrides:
- `work.nix` - Work-specific settings (currently empty)
- `personal.nix` - Personal machine settings (currently empty)
- `macmini.nix` - ClawdBot dependencies (nodejs, pnpm, uv, nerd-fonts)

The `mkHome` function in flake.nix composes these: it loads `home.nix`, the appropriate profile, and sets username/homeDirectory based on the system.
