{ config, pkgs, myuser, options, homedir, inputs, ... }: {
  users = if pkgs.stdenv.isDarwin then {
    users."${myuser}" = {
      home = homedir;
      shell = "${pkgs.fish}/bin/fish";
    };
  } else {
    users = let
      pw =
        "$6$jAVQ7IamcuYQ7qVF$3rUJsm03bpI7SSrzFo2I8/aRQKcZ/upLH3l5NfqnxQWs8FgU2MlcbS0HnLXF2ehBR8dnAWj.ROuCsK91zzNgz.";
    in {
      "${myuser}" = {
        createHome = true;
        home = "/home/${myuser}";
        hashedPassword = pw;
        description = "Kirols Bakheat";
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = [ "audio" "dialout" "input" "kvm" "tty" "video" "wheel" ];
        openssh.authorizedKeys.keys = (import ./secrets/secrets.nix).keys;
      };
      root.hashedPassword = pw;
    };
    mutableUsers = false;
  };

  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  services = if pkgs.stdenv.isDarwin then
    { }
  else {
    flatpak.enable = true;
    gvfs.enable = true;
    journald.extraConfig = "SystemMaxUse=100M";
    onedrive.enable = true;
    openssh = {
      enable = true;
      # settings.PasswordAuthentication = false;
      ports = [ 9639 ];
    };
  };

  nix = {
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      unstable.to = {
        owner = "NixOS";
        repo = "nixpkgs";
        type = "github";
      };
    };
    package = pkgs.nixUnstable;
    checkConfig = false; # incompatible with agenix
    extraOptions = builtins.concatStringsSep "\n" [
      "experimental-features = nix-command flakes recursive-nix repl-flake"
      "include ${config.age.secrets.nix-conf.path}"
    ];
    settings = {
      auto-optimise-store = !pkgs.stdenv.isDarwin;
      extra-sandbox-paths = [ "/etc/ssh" ];
      sandbox = true;
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [ "root" myuser ];
    };
    gc = {
      automatic = !pkgs.stdenv.isDarwin;
      dates = pkgs.lib.mkIf pkgs.stdenv.isLinux "daily";
      options = "--delete-older-than 7d";
    };
    nixPath = options.nix.nixPath.default
      ++ [ "nixpkgs-overlays=${./packages/overlays}" ];
  } // (if pkgs.stdenv.isDarwin then { useDaemon = true; } else { });

  environment = {
    pathsToLink = [ "/share/zsh" ];
    variables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      EDITOR = "vim";
      NIX_AUTO_RUN = "1";
    };
  };
}
