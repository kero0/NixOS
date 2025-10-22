{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.my.home.school;
in
{
  options.my.home.school = {
    enable = mkEnableOption "Enable school specific config options";
  };
  config = mkIf cfg.enable {
    my.home = mkDefault {
      gh.enable = true;
      git.enable = true;
      python.enable = true;
    };
    programs = {
      pandoc = {
        enable = true;
        defaults = {
          pdf-engine = "xelatex";
          metadata = {
            author = osConfig.my.user.realName;
          };
        };
      };
    };
    home.packages = [
      (
        with pkgs.texlive;
        combine {
          inherit
            scheme-small
            biblatex
            dvisvgm
            latexmk
            ;
          inherit
            babel
            capt-of
            environ
            everypage
            float
            fvextra
            needspace
            pdfcol
            siunitx
            soul
            standalone
            subfiles
            tcolorbox
            wrapfig
            xcolor
            ;
        }
      )
    ];
  };
}
