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

    agenix = {
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
      };
      url = "github:ryantm/agenix";
    };

    # PERSONAL
    myXmonadConfig = {
      url = "github:kero0/xmonad";
      flake = false;
    };

    emacs = {
      url = "github:kero0/emacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{ nixpkgs
    , nix
    , nixos-hardware
    , home-manager
    , agenix
    , sops-nix
    , ...
    }:
    let
      mpkgs = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ ] ++ (
            let path = ./packages/overlays;
            in with builtins;
            map (n: import (path + ("/" + n))) (filter
              (n:
                match ".*\\.nix" n != null
                  || pathExists (path + ("/" + n + "/default.nix")))
              (attrNames (readDir path)))
          );
        };
      mhomedir = user: pkgs:
        if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
      mmodules =
        { hostname
        , myuser
        , pkgs
        , homedir ? mhomedir myuser pkgs
        , inc_gui ? pkgs.stdenv.isLinux
        , additional_configs ? [ ]
        , basic_config ? [ ./configuration.nix ./packages ./fonts.nix ]
            ++ nixpkgs.lib.lists.optional pkgs.stdenv.isLinux {
            system.stateVersion = stateVersion;
          }
        , use_hm ? true
        , hm_basic ? [
            ./home-manager
            ./hardware/${hostname}/home
            agenix.homeManagerModules.default
            ./secrets
          ]
        , hm_additional ? [ ]
        }:
        [ ./hardware/${hostname} ] ++ basic_config ++ additional_configs
        ++ nixpkgs.lib.lists.optional inc_gui ./window-manager.nix ++ [
          agenix.${
          if pkgs.stdenv.isLinux then "nixosModules" else "darwinModules"
          }.default
          ./secrets
        ] ++ nixpkgs.lib.lists.optionals use_hm [
          home-manager.${
          if pkgs.stdenv.isLinux then "nixosModules" else "darwinModules"
          }.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit myuser inputs homedir; };
            home-manager.users.${myuser} = {
              home.stateVersion = stateVersion;
              imports = hm_basic ++ hm_additional;
            };
          }
        ];

      stateVersion = "22.05";

    in
      {
        devShells = nixpkgs.lib.foldr nixpkgs.lib.mergeAttrs { } (map
          (system: {
            "${system}".default = import ./shell.nix { pkgs = mpkgs system; };
          }) [ "x86_64-linux" "aarch64-darwin" ]);
        nixosConfigurations = {
          Kirols-xps9575 =
            let
              myuser = "kirolsb";
              system = "x86_64-linux";
              hostname = "Kirols-xps9575";
              homedir = mhomedir myuser pkgs;
              pkgs = mpkgs system;
            in
              nixpkgs.lib.nixosSystem {
                inherit system pkgs;
                specialArgs = { inherit homedir myuser pkgs system inputs; };
                modules = mmodules {
                  inherit hostname myuser pkgs;
                  additional_configs = [
                    nixos-hardware.nixosModules.common-cpu-intel-kaby-lake
                    nixos-hardware.nixosModules.common-gpu-amd
                    nixos-hardware.nixosModules.common-gpu-intel
                    nixos-hardware.nixosModules.common-hidpi
                    nixos-hardware.nixosModules.common-pc-laptop
                    nixos-hardware.nixosModules.common-pc-ssd

                    ./virtualization
                    {
                      services.xserver.windowManager.xmonad.config =
                        pkgs.lib.readFile "${inputs.myXmonadConfig}/xmonad.hs";
                    }
                  ];
                };
              };

        };
        darwinConfigurations."Kirolss-MacBook-Air" =
          let
            system = "aarch64-darwin";
            pkgs = mpkgs system;
            hostname = "Kirolss-MacBook-Air";
            myuser = "kirolsbakheat";
            homedir = mhomedir myuser pkgs;
          in
            inputs.darwin.lib.darwinSystem {
              inherit system;
              specialArgs = { inherit homedir myuser pkgs system inputs; };
              modules = mmodules { inherit myuser pkgs hostname; };

            };
    };
}
