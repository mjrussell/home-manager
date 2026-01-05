{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHome = { system, username, profile }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./profiles/${profile}.nix
            {
              home.username = username;
              home.homeDirectory =
                if nixpkgs.lib.hasSuffix "darwin" system
                then "/Users/${username}"
                else "/home/${username}";
            }
          ];
        };
    in
    {
      homeConfigurations = {
        # Work M1 Mac
        work = mkHome {
          system = "aarch64-darwin";
          username = "matt";
          profile = "work";
        };

        # Personal Intel Mac
        personal = mkHome {
          system = "x86_64-darwin";
          username = "matthewrussell";
          profile = "personal";
        };

        # Personal M1 Mac
        personal-m1 = mkHome {
          system = "aarch64-darwin";
          username = "matthewrussell";
          profile = "personal";
        };

        # Mac Mini (ClawdBot assistant)
        macmini = mkHome {
          system = "aarch64-darwin";
          username = "matt";
          profile = "macmini";
        };
      };
    };
}
