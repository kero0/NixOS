{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.fish;
in
{
  options.my.home.shell.fish.enable = mkEnableOption "Fish module";
  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;

      functions = {
        gitignore = ''
          for arg in $argv
            ${pkgs.curl}/bin/curl -sSL https://www.gitignore.io/api/$arg
          end
        '';
        fish_greeting = "";
        sudo =
          # allows for sudo !! in fish
          ''
            if test "$argv" = !!
              eval command sudo $history[1]
            else
              command sudo $argv
            end
          '';
        __auto_noti = lib.mkIf config.programs.noti.enable {
          body = ''
            if test $CMD_DURATION -gt ${toString (60 * 1000)} # 1 minute
              noti -m "Command $argv finished in $CMD_DURATION ms" -t "$argv"
            end
          '';
          onEvent = "fish_prompt";
        };
      };

      interactiveShellInit =
        with pkgs;
        lib.concatStringsSep "\n" [
          "${any-nix-shell}/bin/any-nix-shell fish --info-right | source"
        ];

      plugins = [
        {
          name = "bass";
          src = pkgs.fetchFromGitHub {
            owner = "edc";
            repo = "bass";
            rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
            sha256 = "0dy53vzzpclw811gxv1kazb8rm7r9dyx56f5ahwd1g38x0pympyx";
          };
        }
      ];
    };
  };
}
