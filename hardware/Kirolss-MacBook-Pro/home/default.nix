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

    activation.InstallApps =
      let
        packages = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages or [ ];
          pathsToLink = "/Applications";
        };
        script = pkgs.writeShellScriptBin "install-apps" ''
          # Set up applications.
          echo "setting up /Applications/Nix Apps..." >&2

          ourLink () {
            local link
            link=$(readlink "$1")
            [ -L "$1" ] && [ "''${link#*-}" = 'system-applications/Applications' ]
          }

          # Clean up for links created at the old location in HOME
          if ourLink ~/Applications; then
            rm ~/Applications
          elif ourLink ~/Applications/'Nix Apps'; then
            rm ~/Applications/'Nix Apps'
          fi

          if [ ! -e '/Applications/Nix Apps' ] \
             || ourLink '/Applications/Nix Apps'; then
            ln -sfn ${packages}/Applications '/Applications/Nix Apps'
          else
            echo "warning: /Applications/Nix Apps is not owned by nix-darwin, skipping App linking..." >&2
          fi
        '';
      in
      ''run ${script}/bin/install-apps'';
    file = {
      ".hammerspoon/init.lua".source = ./hammerspoon.lua;
    };
  };
}
