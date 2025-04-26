{
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://kero0.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "kero0.cachix.org-1:uzu0+ZP6R1U1izim/swa3bfyEiS0TElA8hLrGXQGAbA="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    sandbox = false; # sandbox causing issues on darwin
  };
  inputs = {
    # NixOS related inputs
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
      };
      url = "github:ryantm/agenix";
    };

    emacs.url = "github:kero0/emacs";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      nix,
      nixos-hardware,
      darwin,
      home-manager,
      agenix,
      git-hooks,
      ...
    }:
    let
      nixpkgsConfig = {
        config.allowUnfree = true;
        overlays =
          [ inputs.nixgl.overlay ]
          ++ (
            let
              path = ./overlays;
            in
            with builtins;
            map (n: import (path + ("/" + n))) (
              filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
                attrNames (readDir path)
              )
            )
          );
      };
      mHMmodules =
        hostname: myuser: system:
        let
          isDarwin = nixpkgs.lib.strings.hasSuffix "darwin" system;
          isLinux = nixpkgs.lib.strings.hasSuffix "linux" system;
        in
        (umport {
          ipath = ./modules/home-manager;
          exclude = nixpkgs.lib.lists.optionals isDarwin [
            ./modules/home-manager/nixos-specific
          ];
        })
        ++ (nixpkgs.lib.lists.optionals (builtins.pathExists ./hardware/${hostname}/home) (umport {
          ipath = ./hardware/${hostname}/home;
        }))
        ++ [
          inputs.nix-index-database.hmModules.nix-index
          inputs.catppuccin.homeManagerModules.catppuccin
          (
            { osConfig, ... }:
            {
              nixpkgs = (nixpkgs.lib.mkIf (!(osConfig.home-manager.useGlobalPkgs or false))) nixpkgsConfig;
            }
          )
        ];
      mmodules =
        hostname: myuser: system:
        let
          isDarwin = nixpkgs.lib.strings.hasSuffix "darwin" system;
          isLinux = nixpkgs.lib.strings.hasSuffix "linux" system;
        in
        [
          agenix.${if isLinux then "nixosModules" else "darwinModules"}.default
          ./secrets
          { nixpkgs = nixpkgsConfig; }

          home-manager.${if isLinux then "nixosModules" else "darwinModules"}.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit myuser inputs;
              };
              users.${myuser} = {
                home.stateVersion = stateVersion;
                imports = mHMmodules hostname myuser system;
              };
            };
          }
        ]
        ++ (umport {
          ipath = ./modules/nixos;
          exclude = nixpkgs.lib.lists.optionals isDarwin [ ./modules/nixos/nixos-specific ];
        })
        ++ (nixpkgs.lib.lists.optionals (builtins.pathExists ./hardware/${hostname}/nixos) (umport {
          ipath = ./hardware/${hostname}/nixos;
        }))
        ++ (nixpkgs.lib.lists.optional isLinux { system.stateVersion = stateVersion; })
        ++ (nixpkgs.lib.lists.optional isDarwin {
          programs.bash.enable = true;
          system.stateVersion = 4;
        })
        ++ (nixpkgs.lib.lists.optionals isLinux [
          inputs.catppuccin.nixosModules.catppuccin
          { catppuccin.enable = true; }
        ]);
      umport = import ./umport.nix nixpkgs;
      stateVersion = "22.05";
    in
    {
      umport = ./umport.nix;
      mkHomeConfiguration =
        {
          myuser,
          system,
          hostname,
          homedir ? "/home/${myuser}",
          extraModules ? [ ],
        }:
        {
          "${myuser}" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs (nixpkgsConfig // { inherit system; });
            extraSpecialArgs = {
              inherit
                myuser
                system
                inputs
                ;
              osConfig = { };
              public-keys = (import ./secrets/secrets.nix).keys;
            };
            modules =
              mHMmodules hostname myuser system
              ++ [
                {
                  my.home = {
                    username = myuser;
                    inherit homedir;
                  };
                }
              ]
              ++ extraModules;
          };
        };
      homeConfigurations =
        let
          myuser = "kirolsb";
          system = "x86_64-linux";
          hostname = "personal-home";
        in
        {
          "${myuser}" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs (nixpkgsConfig // { inherit system; });
            extraSpecialArgs = {
              inherit
                myuser
                system
                inputs
                ;
              osConfig = { };
              public-keys = (import ./secrets/secrets.nix).keys;
            };
            modules = mHMmodules hostname myuser system ++ [
              {
                my.home = {
                  username = myuser;
                  homedir = "/home/kirolsb";
                };
              }
            ];
          };
        };
      nixosConfigurations = {
        Kirols-xps9575 =
          let
            myuser = "kirolsb";
            system = "x86_64-linux";
            hostname = "Kirols-xps9575";
          in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit
                myuser
                system
                inputs
                ;
              public-keys = (import ./secrets/secrets.nix).keys;
            };
            modules = mmodules hostname myuser system ++ [
              nixos-hardware.nixosModules.common-cpu-intel
              nixos-hardware.nixosModules.common-gpu-amd
              nixos-hardware.nixosModules.common-hidpi
              nixos-hardware.nixosModules.common-pc-laptop
              nixos-hardware.nixosModules.common-pc-ssd
            ];
          };
      };
      darwinConfigurations."Kirolss-MacBook-Pro" =
        let
          system = "aarch64-darwin";
          hostname = "Kirolss-MacBook-Pro";
          myuser = "kirolsbakheat";
        in
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit
              myuser
              system
              inputs
              ;
            public-keys = (import ./secrets/secrets.nix).keys;
          };
          modules = mmodules hostname myuser system;
        };
      formatter = {
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      };
      checks =
        let
          f = system: {
            ${system}.pre-commit-check = git-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                nixfmt-rfc-style = {
                  enable = true;
                  package = self.formatter.${system};
                };
                statix.enable = true;
              };
            };
          };
        in
        f "aarch64-darwin" // f "x86_64-linux";
      devShells =
        let
          f = system: {
            ${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
              inherit (self.checks.${system}.pre-commit-check) shellHook;
              buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            };
          };
        in
        f "aarch64-darwin" // f "x86_64-linux";
    };
}
