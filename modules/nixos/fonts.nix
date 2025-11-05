{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.fonts;
in
with lib;
{
  options.my.fonts.enable = mkEnableOption "Enable my fonts";
  config = lib.mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        dejavu_fonts
        font-awesome
        julia-mono
        nerd-fonts.jetbrains-mono
        noto-fonts-color-emoji
      ];
    }
    // (optionalAttrs pkgs.stdenv.isLinux {
      enableDefaultPackages = true;
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "DejaVu Serif" ];
          sansSerif = [ "FuraCode Nerd Font" ];
          monospace = [ "JetBrainsMono Nerd Font Mono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    });
  };
}
