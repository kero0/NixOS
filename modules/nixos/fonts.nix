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
    fonts =
      {
        packages =
          with pkgs;
          [
            font-awesome
            julia-mono
            nerd-fonts.jetbrains-mono
          ]
          ++ (lib.optionals (!pkgs.stdenv.isDarwin) [
            dejavu_fonts
            noto-fonts-emoji
          ]);
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
