{ config, pkgs, lib, ... }:

let
  fdBin = "${pkgs.fd}/bin/fd";
  batBin = "${pkgs.bat}/bin/bat";
  treeBin = "${pkgs.tree}/bin/tree";
in
{
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    GPG_TTY = "/dev/ttys000";
    EDITOR = "nvim";
    VISUAL = "nvim";
    CLICOLOR = 1;
    LSCOLORS = "ExFxBxDxCxegedabagacad";
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
  };

  home.packages = with pkgs; [
    tree
    fd
    ripgrep
    curl
    jq
    htop
    github-cli
    cachix
    ffmpeg
    gawk
    gnugrep
    gnupg
    gnused
    nix
    nixfmt-classic
    nixpkgs-fmt
    coreutils-full
    pre-commit
    python3
    rsync
    shellcheck
    zsh-completions
  ];

  # Zsh with oh-my-zsh and plugins
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    localVariables = {
      LANG = "en_US.UTF-8";
      GPG_TTY = "/dev/ttys000";
      DEFAULT_USER = config.home.username;
      CLICOLOR = 1;
      LS_COLORS = "ExFxBxDxCxegedabagacad";
      TERM = "xterm-256color";
    };
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
    };
    plugins = [
      { name = "zsh-nix-shell"; src = pkgs.zsh-nix-shell; file = "share/zsh/plugins/zsh-nix-shell/nix-shell.plugin.zsh"; }
      { name = "zsh-autopair"; src = pkgs.zsh-autopair; file = "share/zsh/zsh-autopair/autopair.zsh"; }
      { name = "zsh-bd"; src = pkgs.zsh-bd; file = "share/plugins/zsh-bd/bd.zsh"; }
      { name = "zsh-autosuggestions"; src = pkgs.zsh-autosuggestions; file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"; }
      { name = "zsh-fast-syntax-highlighting"; src = pkgs.zsh-fast-syntax-highlighting; file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"; }
      { name = "zsh-history-substring-search"; src = pkgs.zsh-history-substring-search; file = "share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"; }
    ];
    shellAliases = {
      vimdiff = "nvim -d";
      z = "j";
      cachix = "op plugin run -- cachix";
      gh = "op plugin run -- gh";
    } // lib.optionalAttrs pkgs.stdenvNoCC.isDarwin {
      ibrew = "arch -x86_64 brew";
      abrew = "arch -arm64 brew";
    };
    initExtra = ''
      if command -v op >/dev/null; then
        eval "$(op completion zsh)"; compdef _op op
      fi

      function weather() {
          curl wttr.in/$1
      }

      function service() {
          if [[ -z "$1" ]]; then
              echo "no command provided from [stop, start, restart]"
              return 1
          fi
          if [[ -z "$2" ]]; then
              echo "No service name provided"
              return 1
          fi

          service=$(launchctl list | awk "/$2/ {print $NF}")
          if [[ "$1" == "restart" ]]; then
              launchctl stop $service && launchctl start $service
          else
              launchctl $1 $service
          fi
      }

      if [[ -d /opt/homebrew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      unset RPS1
      bindkey '^ ' autosuggest-accept

      # Activate `fnm`: https://github.com/Schniz/fnm
      if command -v fnm >/dev/null; then
          eval "$(fnm env --use-on-cd)"
      fi

      ulimit -n 4096
    '';
  };

  programs.bash = {
    enable = true;
    shellAliases = lib.optionalAttrs pkgs.stdenvNoCC.isDarwin {
      ibrew = "arch -x86_64 brew";
      abrew = "arch -arm64 brew";
    };
  };

  programs.autojump = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$localip"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$nix_shell"
        "$aws"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];
      git_status.stashed = "";
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    defaultCommand = "${fdBin} -H --type f";
    defaultOptions = [ "--height 50%" ];
    fileWidgetCommand = "${fdBin} -H --type f";
    fileWidgetOptions = [ "--preview '${batBin} --color=always --plain --line-range=:200 {}'" ];
    changeDirWidgetCommand = "${fdBin} --type d";
    changeDirWidgetOptions = [ "--preview '${treeBin} -C {} | head -200'" ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      color = "always";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.jq.enable = true;
  programs.htop.enable = true;
  programs.gpg.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "Matthew Russell";
      credential.helper =
        if pkgs.stdenvNoCC.isDarwin
        then "osxkeychain"
        else "cache --timeout=1000000000";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.followTags = true;
      fetch.prune = true;
      commit.verbose = true;
      http.sslVerify = true;
      core.editor = "vim";
      core.pager = "${pkgs.delta}/bin/delta";
      interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
      alias = {
        fix = "commit --amend --no-edit";
        oops = "reset HEAD~1";
      };
      # 1Password git signing
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      commit.gpgsign = true;
    };
    includes = [
      {
        condition = "gitdir:~/code/personal/";
        contents = {
          user.email = "matthewjosephrussell@gmail.com";
          user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsuQpHchfqyjLQoKLQt6KLtvGeGbJK6krwUxVLjbNzd";
        };
      }
      {
        condition = "gitdir:~/code/mercury/";
        contents = {
          user.email = "mattrussell@mercury.com";
          user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwusIGOug/7M1ybmoueCTJyGT0GSzpUUtSZdlzm0YJR";
        };
      }
    ];
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      light = false;
    };
  };

  # Symlink 1Password agent socket on macOS
  home.file.".1password/agent.sock".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      extraOptions = {
        IdentityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
      };
    };
  };
}
