{ config, pkgs, lib, ... }:

{
  # Use local SSH key instead of 1Password agent
  home.sessionVariables.SSH_AUTH_SOCK = lib.mkForce "";

  programs.ssh = {
    matchBlocks."*" = {
      identityFile = "~/.ssh/id_ed25519";
    };
  };

}
