{
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
      mpkgs =
        system:
        import nixpkgs {
          inherit system;
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
        hostname: myuser: pkgs:
        (umport {
          ipath = ./modules/home-manager;
          exclude = nixpkgs.lib.lists.optionals pkgs.stdenv.isDarwin [
            ./modules/home-manager/nixos-specific
          ];
        })
        ++ (umport { ipath = ./hardware/${hostname}/home; })
        ++ [
          inputs.nix-index-database.hmModules.nix-index
          inputs.catppuccin.homeManagerModules.catppuccin
        ];
      mmodules =
        hostname: myuser: pkgs:
        [
          agenix.${if pkgs.stdenv.isLinux then "nixosModules" else "darwinModules"}.default
          ./secrets

          home-manager.${if pkgs.stdenv.isLinux then "nixosModules" else "darwinModules"}.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit myuser inputs;
              };
              users.${myuser} = {
                home.stateVersion = stateVersion;
                imports = mHMmodules hostname myuser pkgs;
              };
            };
          }
        ]
        ++ (umport {
          ipath = ./modules/nixos;
          exclude = nixpkgs.lib.lists.optionals pkgs.stdenv.isDarwin [ ./modules/nixos/nixos-specific ];
        })
        ++ (umport { ipath = ./hardware/${hostname}/nixos; })
        ++ (nixpkgs.lib.lists.optional pkgs.stdenv.isLinux { system.stateVersion = stateVersion; })
        ++ (nixpkgs.lib.lists.optional pkgs.stdenv.isDarwin {
          programs.bash.enable = true;
          system.stateVersion = 4;
        })
        ++ (nixpkgs.lib.lists.optionals pkgs.stdenv.isLinux [
          inputs.catppuccin.nixosModules.catppuccin
          ({ catppuccin.enable = true; })
        ]);
      umport = import ./umport.nix nixpkgs;
      stateVersion = "22.05";
    in
    {
      homeConfigurations =
        (
          let
            myuser = "kbakheat@na1.ford.com";
            system = "x86_64-linux";
            hostname = "work";
            pkgs = mpkgs system;
          in
          {
            "${myuser}" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit
                  myuser
                  pkgs
                  system
                  inputs
                  ;
                osConfig = { };
                public-keys = (import ./secrets/secrets.nix).keys;
              };
              modules = mHMmodules hostname myuser pkgs ++ [
                {
                  my.home = {
                    username = myuser;
                    homedir = "/home/kbakheat";
                  };
                }
              ];
            };
          }
        )
        // (
          let
            myuser = "kbakheat-local";
            system = "x86_64-linux";
            hostname = "work";
            pkgs = mpkgs system;
          in
          {
            "${myuser}" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit
                  myuser
                  pkgs
                  system
                  inputs
                  ;
                osConfig = { };
                public-keys = (import ./secrets/secrets.nix).keys;
              };
              modules = mHMmodules hostname myuser pkgs ++ [
                {
                  my.home = {
                    username = myuser;
                    homedir = "/home/kbakheat-local";
                  };
                }
              ];
            };
          }
        );
      nixosConfigurations = {
        Kirols-xps9575 =
          let
            myuser = "kirolsb";
            system = "x86_64-linux";
            hostname = "Kirols-xps9575";
            pkgs = mpkgs system;
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            specialArgs = {
              inherit
                myuser
                pkgs
                system
                inputs
                ;
              public-keys = (import ./secrets/secrets.nix).keys;
            };
            modules = mmodules hostname myuser pkgs ++ [
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
          pkgs = mpkgs system;
          hostname = "Kirolss-MacBook-Pro";
          myuser = "kirolsbakheat";
        in
        darwin.lib.darwinSystem {
          inherit system pkgs;
          specialArgs = {
            inherit
              myuser
              pkgs
              system
              inputs
              ;
            public-keys = (import ./secrets/secrets.nix).keys;
          };
          modules = mmodules hostname myuser pkgs;
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
              };
            };
          };
        in
        (f "aarch64-darwin" // f "x86_64-linux");
      devShell =
        let
          f = system: {
            ${system} = nixpkgs.legacyPackages.${system}.mkShell {
              inherit (self.checks.${system}.pre-commit-check) shellHook;
              buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            };
          };
        in
        (f "aarch64-darwin" // f "x86_64-linux");
    };
}
