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

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
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
      pre-commit-hooks,
      ...
    }:
    let
      mpkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays =
            [ ]
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
                imports =
                  (umport {
                    ipath = ./modules/home-manager;
                    exclude = nixpkgs.lib.lists.optionals pkgs.stdenv.isDarwin [
                      ./modules/home-manager/nixos-specific
                    ];
                  })
                  ++ (umport { ipath = ./hardware/${hostname}/home; })
                  ++ [ inputs.nix-index-database.hmModules.nix-index ];
              };
            };
          }
        ]
        ++ (umport {
          ipath = ./modules/nixos;
          exclude = nixpkgs.lib.lists.optionals pkgs.stdenv.isDarwin [ ./modules/nixos/nixos-specific ];
        })
        ++ (umport { ipath = ./hardware/${hostname}/nixos; })
        ++ (nixpkgs.lib.lists.optional pkgs.stdenv.isLinux { system.stateVersion = stateVersion; });
      umport = import ./umport.nix nixpkgs;
      stateVersion = "22.05";
    in
    {
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
              nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
              nixos-hardware.nixosModules.common-gpu-amd
              nixos-hardware.nixosModules.common-gpu-intel
              nixos-hardware.nixosModules.common-hidpi
              nixos-hardware.nixosModules.common-pc-laptop
              nixos-hardware.nixosModules.common-pc-ssd
            ];
          };
        mars =
          let
            myuser = "kirolsb";
            system = "x86_64-linux";
            hostname = "mars";
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
              nixos-hardware.nixosModules.common-cpu-amd
              nixos-hardware.nixosModules.common-cpu-amd-pstate
              nixos-hardware.nixosModules.common-cpu-amd-raphael-igpu
              nixos-hardware.nixosModules.common-gpu-amd
              nixos-hardware.nixosModules.common-pc-laptop
              nixos-hardware.nixosModules.common-pc-ssd
            ];
          };
      };
      darwinConfigurations."Kirolss-MacBook-Air" =
        let
          system = "aarch64-darwin";
          pkgs = mpkgs system;
          hostname = "Kirolss-MacBook-Air";
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
            ${system}.pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                nixfmt = {
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
