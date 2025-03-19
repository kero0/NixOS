{
  pkgs,
  lib,
  config,
  inputs,
  options,
  ...
}:
{
  programs = {
    bash = {
      completion.enable = true;
    };
    fish.enable = true;
    zsh.enable = true;
  };
  nix = {
    checkConfig = false; # incompatible with agenix
    extraOptions = builtins.concatStringsSep "\n" [
      "experimental-features = nix-command flakes recursive-nix"
      "!include ${config.age.secrets.nix-conf.path}"
    ];
    settings = {
      auto-optimise-store = !pkgs.stdenv.isDarwin;
      extra-sandbox-paths = [ "/etc/ssh" ];
      sandbox = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://kero0.cachix.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "kero0.cachix.org-1:uzu0+ZP6R1U1izim/swa3bfyEiS0TElA8hLrGXQGAbA="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      trusted-users = [
        "root"
        config.my.user.username
      ];
    };
    gc = {
      automatic = !pkgs.stdenv.isDarwin;
      dates = pkgs.lib.mkIf pkgs.stdenv.isLinux "daily";
      options = "--delete-older-than 7d";
    };
  };

  environment = {
    pathsToLink = [ "/share/zsh" ];
    variables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      EDITOR = "vim";
    };
  };
}
