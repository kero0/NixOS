{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.rofi;
in
{
  options.my.home.rofi.enable = mkEnableOption "Enable rofi";
  config = mkIf cfg.enable {
    programs.rofi = pkgs.lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      font = "JetBrainsMono Nerd Font 28";
      terminal = lib.mkIf config.programs.kitty.enable "kitty";
      cycle = true;
      location = "center";
      modes = [
        "drun"
        "run"
      ]
      ++ lists.optional config.my.home.clipboard-manager.enable {
        name = "clipboard";
        path = "${pkgs.cliphist}/bin/cliphist-rofi-img";
      };
      theme = {
        "#window" = {
          fullscreen = true;
        };
      };
      extraConfig = {
        kb-primary-paste = "Control+V,Shift+Insert";
        kb-secondary-paste = "Control+v,Insert";
        matching = "regex";
      };
    };
  };
}
