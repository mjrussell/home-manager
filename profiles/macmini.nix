{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ClawdBot dependencies
    nodejs_22
    pnpm

    # For MCP servers (python3 already in base home.nix)
    uv

    # Nerd font for terminal/starship
    nerd-fonts.meslo-lg
  ];

  home.sessionVariables = {
    CLAWDBOT_NIX_MODE = "1";
  };
}
