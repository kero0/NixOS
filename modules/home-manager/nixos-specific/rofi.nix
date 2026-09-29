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
    programs.rofi = pkgs.lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      enable = true;
      theme = {
        "#window" = {
          fullscreen = true;
        };
      };
      settings = {
        modes = [
          "drun"
          "run"
          "clipboard:${pkgs.cliphist}/bin/cliphist-rofi-img"
        ];
        font = "JetBrainsMono Nerd Font 28";
        terminal = lib.mkIf config.programs.kitty.enable "kitty";
        cycle = true;
        kb-primary-paste = "Control+V,Shift+Insert";
        kb-secondary-paste = "Control+v,Insert";
        matching = "regex";
      };
    };
  };
}
