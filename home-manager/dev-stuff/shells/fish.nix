{ config, lib, pkgs, modulesPath, ... }: {
  programs.fish = {
    enable = true;

    functions = {
      gitignore = ''
        for arg in $argv
          ${pkgs.curl}/bin/curl -sSL https://www.gitignore.io/api/$arg
        end
      '';
      fish_greeting = "";
      clear = ''
        command clear
        ${pkgs.dwt1-shell-color-scripts}/bin/colorscript random
      '';
      sudo = # allows for sudo !! in fish
        ''
          if test "$argv" = !!
            eval command sudo $history[1]
          else
            command sudo $argv
          end
        '';

      __fish_command_not_found_handler = {
        body = "${pkgs.comma}/bin/, $argv";
        onEvent = "fish_command_not_found";
      };
      __auto_noti = lib.mkIf config.programs.noti.enable {
        body = ''
          if test $CMD_DURATION -gt ${toString (60 * 1000)} # 1 minute
            noti -m "Command $argv finished in $CMD_DURATION ms" -t "$argv"
          end
        '';
        onEvent = "fish_prompt";
      };
    };

    interactiveShellInit = with pkgs;
      lib.concatStringsSep "\n" [
        "${any-nix-shell}/bin/any-nix-shell fish --info-right | source"

        "${dwt1-shell-color-scripts}/bin/colorscript random"
      ];

    plugins = [{
      name = "bass";
      src = pkgs.fetchFromGitHub {
        owner = "edc";
        repo = "bass";
        rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
        sha256 = "0dy53vzzpclw811gxv1kazb8rm7r9dyx56f5ahwd1g38x0pympyx";
      };
    }];
  };
}

