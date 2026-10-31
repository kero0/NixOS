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
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit.follows = "git-hooks";
      };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # keeps its own nixpkgs on purpose: its port sources are built with it, and
    # following ours would rebuild every theme on each nixpkgs bump
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
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ryantm/agenix";
    };

    emacs = {
      url = "github:kero0/emacs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        git-hooks.follows = "git-hooks";
        emacs-overlay.inputs = {
          nixpkgs.follows = "nixpkgs";
          nixpkgs-stable.follows = "nixpkgs";
        };
      };
    };

    coptic-font-conversion = {
      url = "github:kero0/coptic-font-conversion";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    jdf = {
      url = "github:iamjakewarner/jdf";
      flake = false;
    };
    tmux-ssh-split = {
      url = "github:pschmitt/tmux-ssh-split";
      flake = false;
    };
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
      inherit (nixpkgs) lib;
      stateVersion = "22.05";
      public-keys = import ./secrets/keys.nix;
      umport = import ./utils/umport.nix nixpkgs;

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      pkgsFor = system: import nixpkgs (nixpkgsConfig // { inherit system; });
      forAllSystems = f: lib.genAttrs systems (system: f (pkgsFor system));

      nixpkgsConfig = {
        config.allowUnfree = true;
        overlays = map import (umport {
          ipath = ./overlays;
        });
      };
      mHMmodules =
        {
          hostname,
          system,
          age ? true,
        }:
        let
          isDarwin = lib.hasSuffix "darwin" system;
          hostDir = ./hardware/${hostname}/home;
        in
        umport {
          ipath = ./modules/home-manager;
          exclude = lib.optional isDarwin ./modules/home-manager/nixos-specific;
        }
        ++ lib.optionals (builtins.pathExists hostDir) (umport {
          ipath = hostDir;
        })
        ++ [
          inputs.nix-index-database.homeModules.nix-index
          inputs.catppuccin.homeModules.catppuccin
          {
            catppuccin = {
              enable = true;
              autoEnable = true;
            };
          }
          (
            { osConfig, ... }:
            {
              nixpkgs = lib.mkIf (!(osConfig.home-manager.useGlobalPkgs or false)) nixpkgsConfig;
            }
          )
        ]
        ++ lib.optional age agenix.homeManagerModules.default
        ++ lib.optional age ./secrets;

      mmodules =
        {
          hostname,
          myuser,
          system,
          age ? true,
        }:
        let
          isDarwin = lib.hasSuffix "darwin" system;
          isLinux = lib.hasSuffix "linux" system;
          kind = if isLinux then "nixosModules" else "darwinModules";
          hostDir = ./hardware/${hostname}/nixos;
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
          home-manager.${kind}.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              overwriteBackup = true;
              extraSpecialArgs = { inherit inputs; };
              users.${myuser} = {
                home.stateVersion = stateVersion;
                imports = mHMmodules { inherit hostname system; };
              };
            };
          }
        ]
        ++ umport {
          ipath = ./modules/nixos;
          exclude = lib.optional isDarwin ./modules/nixos/nixos-specific;
        }
        ++ lib.optionals (builtins.pathExists hostDir) (umport {
          ipath = hostDir;
        })
        ++ lib.optional age agenix.${kind}.default
        ++ lib.optional age ./secrets
        ++ lib.optional isLinux { system.stateVersion = stateVersion; }
        ++ lib.optional isDarwin {
          programs.bash.enable = true;
          system.stateVersion = 4;
        }
        ++ lib.optionals isLinux [
          inputs.catppuccin.nixosModules.catppuccin
          {
            catppuccin = {
              enable = true;
              autoEnable = true;
            };
          }
          inputs.disko.nixosModules.disko
          { networking.hostName = hostname; }
        ];

      mkNixos =
        hostname:
        {
          system ? "x86_64-linux",
          myuser ? "kirolsb",
          age ? true,
          modules ? [ ],
        }:
        lib.nixosSystem {
          modules =
            mmodules {
              inherit
                hostname
                myuser
                system
                age
                ;
            }
            ++ modules;
        };

      mkHomeConfiguration =
        {
          myuser,
          system,
          hostname,
          homedir ? "/home/${myuser}",
          extraModules ? [ ],
        }:
        {
          ${myuser} = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsFor system;
            extraSpecialArgs = { inherit inputs; };
            modules =
              mHMmodules { inherit hostname system; }
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
    in
    {
      inherit
        mmodules
        umport
        public-keys
        mkHomeConfiguration
        ;

      nixosConfigurations = lib.mapAttrs mkNixos {
        Kirols-xps9575.modules = with nixos-hardware.nixosModules; [
          common-cpu-intel
          common-gpu-amd
          common-hidpi
          common-pc-laptop
          common-pc-ssd
        ];
        theater = {
          age = false;
          modules = with nixos-hardware.nixosModules; [
            common-cpu-intel
            common-gpu-amd
            common-pc
            common-pc-ssd
          ];
        };
        hass = {
          age = false;
          modules = [ nixos-hardware.nixosModules.gmktec-nucbox-g3-plus ];
        };
        justice.modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-l13-yoga
          inputs.lanzaboote.nixosModules.lanzaboote
        ];
        tang = {
          system = "aarch64-linux";
          age = false;
        };
      };

      darwinConfigurations.Kirolss-MacBook-Pro = darwin.lib.darwinSystem {
        modules = mmodules {
          hostname = "Kirolss-MacBook-Pro";
          myuser = "kirolsbakheat";
          system = "aarch64-darwin";
        };
      };

      homeConfigurations = mkHomeConfiguration {
        myuser = "kirolsb";
        system = "x86_64-linux";
        hostname = "personal-home";
      };

      images = import ./utils/images.nix { inherit mmodules nixpkgs self; };
      vms = import ./utils/vms.nix { inherit nixpkgs self; };
      packages = forAllSystems (pkgs: import ./utils/scripts { inherit self pkgs; });
      formatter = lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      checks = lib.genAttrs systems (system: {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            deadnix.enable = true;
            flake-checker.enable = true;
            statix.enable = true;
            nixfmt = {
              enable = true;
              package = nixpkgs.legacyPackages.${system}.nixfmt;
            };
          };
        };
      });

      devShells = forAllSystems (
        pkgs:
        let
          check = self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check;
        in
        {
          default = pkgs.mkShell {
            inherit (check) shellHook;
            buildInputs = check.enabledPackages ++ [ pkgs.age ];
          };
        }
      );
    };
}
