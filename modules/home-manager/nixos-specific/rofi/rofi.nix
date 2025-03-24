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
  config = mkIf cfg.enable ({
    catppuccin.rofi.enable = false;
    programs.rofi = pkgs.lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      font = "JetBrainsMono Nerd Font 14";
      terminal = "${pkgs.kitty}/bin/kitty";
      cycle = true;
      location = "center";
      theme = toString (
        pkgs.writeText "theme.rasi" ''
          @import "${pkgs.catppuccin + /rofi/catppuccin-macchiato.rasi}"
          #window { fullscreen: true; }
        ''
      );
      extraConfig = {
        modi = "drun,run,window,ssh,";
        kb-primary-paste = "Control+V,Shift+Insert";
        kb-secondary-paste = "Control+v,Insert";
        matching = "regex";
        dpi = 1;
      };
    };
  });
}
