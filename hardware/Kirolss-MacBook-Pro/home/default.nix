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
  home = {
    packages = with pkgs; [
      # java development
      (maven.overrideAttrs (old: {
        java = config.programs.java.package;
      }))
    ];
    file = {
      ".hammerspoon/init.lua".source = ./hammerspoon.lua;
    };
  };
}
