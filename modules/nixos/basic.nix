{
  pkgs,
  lib,
  config,
  age,
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
    extraOptions = builtins.concatStringsSep "\n" [
      (lib.strings.optionalString (
        age && config.age.secrets ? nix-conf
      ) "!include ${config.age.secrets.nix-conf.path}")
    ];
    settings = {
      auto-optimise-store = !pkgs.stdenv.isDarwin;
      experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
        "pipe-operators"
      ];
      sandbox = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://kero0.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "kero0.cachix.org-1:uzu0+ZP6R1U1izim/swa3bfyEiS0TElA8hLrGXQGAbA="
      ];
      trusted-users = [
        "root"
        config.my.user.username
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    optimise = {
      automatic = true;
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
