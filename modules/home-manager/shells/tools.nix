{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.home.shell.tools;
in
{
  options.my.home.shell.tools.enable = mkEnableOption "Basic shell tools";
  config = mkIf cfg.enable {
    services = {
      lorri = {
        enable = pkgs.stdenv.hostPlatform.isLinux;
        enableNotifications = true;
      };
    };
    programs = {
      command-not-found.enable = false;
      eza.enable = true;
      feh.enable = pkgs.stdenv.hostPlatform.isLinux;
      jq.enable = true;
      man.enable = true;
      zathura.enable = pkgs.stdenv.hostPlatform.isLinux;

      direnv = {
        enable = true;
        nix-direnv.enable = true;
        config = {
          global = {
            load_dotenv = true;
            strict_env = true;
          };
        };
      };

      fd = {
        enable = true;
        hidden = true;
        extraOptions = [ "--absolute-path" ];
        ignores = [
          ".git/"
          "*.bak"
        ];
      };

      fzf = {
        enable = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        historyWidget.command = "";
      };

      ripgrep = {
        enable = true;
        arguments = [
          "--smart-case"
          "--hidden"
          "--glob=!.git/*"
        ];
      };
    };
  };
}
