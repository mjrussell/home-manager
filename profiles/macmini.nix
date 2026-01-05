{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # ClawdBot dependencies
    nodejs_22
    pnpm

    # For MCP servers (python3 already in base home.nix)
    uv
  ];

  home.sessionVariables = {
    CLAWDBOT_NIX_MODE = "1";
  };
}
