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
        ${if pkgs.stdenv.isDarwin then "fonts" else "packages"} =
          with pkgs;
          [
            font-awesome
            julia-mono
            (nerdfonts.override {
              fonts = [
                "FiraCode"
                "FiraMono"
                "JetBrainsMono"
              ];
            })
          ]
          ++ (lib.optionals (!pkgs.stdenv.isDarwin) [
            dejavu_fonts
            noto-fonts-emoji
          ]);
      }
      // (
        if pkgs.stdenv.isDarwin then
          { fontDir.enable = true; }
        else
          {
            fontconfig = {
              enable = true;
              defaultFonts = {
                serif = [ "DejaVu Serif" ];
                sansSerif = [ "FuraCode Nerd Font" ];
                monospace = [ "JetBrainsMono Nerd Font Mono" ];
                emoji = [ "Noto Color Emoji" ];
              };
            };
          }
      );
  };
}
