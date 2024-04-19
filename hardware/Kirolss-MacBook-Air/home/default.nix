{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  programs.java = {
    enable = true;
    package = pkgs.openjdk17;
  };
  home.packages = with pkgs; [
    # website development
    hugo
    lilypond-unstable

    # java development
    (maven.overrideAttrs (old: {
      java = config.programs.java.package;
    }))

    # communication
    discord
  ];
  home.file = {
    "Applications/Nix Apps".source = "${
      pkgs.buildEnv {
        name = "home-manager-applications";
        paths = osConfig.environment.systemPackages;
        pathsToLink = "/Applications";
      }
    }/Applications";
    ".hammerspoon/init.lua".source = ./hammerspoon.lua;
  };
}
