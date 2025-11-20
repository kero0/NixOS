{
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://kero0.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "kero0.cachix.org-1:uzu0+ZP6R1U1izim/swa3bfyEiS0TElA8hLrGXQGAbA="
    ];
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
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
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
          let
            path = ./overlays;
          in
          with builtins;
          map (n: import (path + ("/" + n))) (
            filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
              attrNames (readDir path)
            )
          );
      };
      mHMmodules =
        {
          hostname,
          myuser,
          system,
          age ? true,
          defaultsecrets ? age,
          exclude ? [ ],
        }:
        let
          isDarwin = nixpkgs.lib.strings.hasSuffix "darwin" system;
          isLinux = nixpkgs.lib.strings.hasSuffix "linux" system;
        in
        (umport {
          ipath = ./modules/home-manager;
          exclude =
            nixpkgs.lib.lists.optionals isDarwin [
              ./modules/home-manager/nixos-specific
            ]
            ++ exclude;
        })
        ++ (nixpkgs.lib.lists.optionals (builtins.pathExists ./hardware/${hostname}/home) (umport {
          ipath = ./hardware/${hostname}/home;
          inherit exclude;
        }))
        ++ [
          inputs.nix-index-database.homeModules.nix-index
          inputs.catppuccin.homeModules.catppuccin
          (
            { osConfig, ... }:
            {
              nixpkgs = (nixpkgs.lib.mkIf (!(osConfig.home-manager.useGlobalPkgs or false))) nixpkgsConfig;
              _module.args = {
                inherit
                  myuser
                  public-keys
                  system

                  inputs
                  age
                  ;
              };
            }
          )
        ]
        ++ nixpkgs.lib.lists.optional age agenix.homeManagerModules.default
        ++ nixpkgs.lib.lists.optional defaultsecrets ./secrets;
      mmodules =
        {
          hostname,
          myuser,
          system,
          age ? true,
          defaultsecrets ? age,
          exclude ? [ ],
        }:
        let
          isDarwin = nixpkgs.lib.strings.hasSuffix "darwin" system;
          isLinux = nixpkgs.lib.strings.hasSuffix "linux" system;
        in
        [
          {
            nixpkgs = nixpkgsConfig // {
              hostPlatform = { inherit system; };
            };
            _module.args = {
              inherit
                myuser
                public-keys

                inputs
                age
                ;
            };
          }

          home-manager.${if isLinux then "nixosModules" else "darwinModules"}.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit
                  myuser
                  public-keys
                  system

                  inputs
                  ;
              };
              users.${myuser} = {
                home.stateVersion = stateVersion;
                imports = mHMmodules {
                  inherit
                    hostname
                    myuser
                    system
                    exclude
                    ;
                };
              };
            };
          }
        ]
        ++ umport {
          ipath = ./modules/nixos;
          exclude = nixpkgs.lib.lists.optionals isDarwin [ ./modules/nixos/nixos-specific ] ++ exclude;
        }
        ++ nixpkgs.lib.lists.optionals (builtins.pathExists ./hardware/${hostname}/nixos) (umport {
          ipath = ./hardware/${hostname}/nixos;
          inherit exclude;
        })
        ++
          nixpkgs.lib.lists.optional age
            agenix.${if isLinux then "nixosModules" else "darwinModules"}.default
        ++ nixpkgs.lib.lists.optional defaultsecrets ./secrets

        ++ nixpkgs.lib.lists.optional isLinux { system.stateVersion = stateVersion; }
        ++ nixpkgs.lib.lists.optional isDarwin {
          programs.bash.enable = true;
          system.stateVersion = 4;
        }
        ++ nixpkgs.lib.lists.optionals isLinux [
          inputs.catppuccin.nixosModules.catppuccin
          { catppuccin.enable = true; }
          inputs.disko.nixosModules.disko
          { networking.hostName = hostname; }
        ];
      umport = import ./utils/umport.nix nixpkgs;
      public-keys = import ./secrets/keys.nix;
      stateVersion = "22.05";
    in
    {
      inherit mmodules umport public-keys;
      mkHomeConfiguration =
        {
          myuser,
          system,
          hostname,
          homedir ? "/home/${myuser}",
          extraModules ? [ ],
          exclude ? [ ],
        }:
        {
          "${myuser}" = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs (nixpkgsConfig // { inherit system; });
            extraSpecialArgs = {
              inherit
                myuser
                public-keys
                system

                inputs
                ;
            };
            modules =
              mHMmodules {
                inherit
                  hostname
                  myuser
                  system
                  exclude
                  ;
              }
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
            modules = mHMmodules { inherit hostname myuser system; } ++ [
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
            modules = mmodules { inherit hostname myuser system; } ++ [
              nixos-hardware.nixosModules.common-cpu-intel
              nixos-hardware.nixosModules.common-gpu-amd
              nixos-hardware.nixosModules.common-hidpi
              nixos-hardware.nixosModules.common-pc-laptop
              nixos-hardware.nixosModules.common-pc-ssd
            ];
          };
        theater =
          let
            myuser = "kirolsb";
            system = "x86_64-linux";
            hostname = "theater";
          in
          nixpkgs.lib.nixosSystem {
            modules =
              mmodules {
                inherit hostname myuser system;
                age = false;
              }
              ++ [
                nixos-hardware.nixosModules.common-cpu-intel
                nixos-hardware.nixosModules.common-gpu-amd
                nixos-hardware.nixosModules.common-pc
                nixos-hardware.nixosModules.common-pc-ssd
              ];
          };
        hass =
          let
            myuser = "kirolsb";
            system = "x86_64-linux";
            hostname = "hass";
          in
          nixpkgs.lib.nixosSystem {
            modules =
              mmodules {
                inherit hostname myuser system;
                age = false;
              }
              ++ [
                nixos-hardware.nixosModules.gmktec-nucbox-g3-plus
              ];
          };
        justice =
          let
            myuser = "kirolsb";
            system = "x86_64-linux";
            hostname = "justice";
          in
          nixpkgs.lib.nixosSystem {
            modules = mmodules { inherit hostname myuser system; } ++ [
              nixos-hardware.nixosModules.lenovo-thinkpad-l13-yoga
              inputs.lanzaboote.nixosModules.lanzaboote
            ];
          };
        tang =
          let
            myuser = "kirolsb";
            system = "aarch64-linux";
            hostname = "tang";
          in
          nixpkgs.lib.nixosSystem {
            modules = mmodules {
              inherit hostname myuser system;
              age = false;
            };
          };
      };
      images = import ./utils/images.nix { inherit mmodules nixpkgs self; };
      vms = import ./utils/vms.nix { inherit nixpkgs self; };
      darwinConfigurations."Kirolss-MacBook-Pro" =
        let
          system = "aarch64-darwin";
          hostname = "Kirolss-MacBook-Pro";
          myuser = "kirolsbakheat";
        in
        darwin.lib.darwinSystem {
          modules = mmodules { inherit hostname myuser system; };
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
          f =
            system:
            let
              pkgs = import nixpkgs (nixpkgsConfig // { inherit system; });
            in
            {
              ${system}.default = pkgs.mkShell {
                inherit (self.checks.${system}.pre-commit-check) shellHook;
                buildInputs = self.checks.${system}.pre-commit-check.enabledPackages ++ [ pkgs.age ];
              };
            };
        in
        f "aarch64-darwin" // f "x86_64-linux";
    };
}
