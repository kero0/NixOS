{
  pkgs,
  lib,
  config,
  inputs,
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
    my.home = {
      gh.enable = mkDefault true;
      git.enable = mkDefault true;
      python.enable = mkDefault true;
    };
    programs.pandoc.enable = true;
    home.packages =
      let
        jdf = pkgs.stdenvNoCC.mkDerivation {
          name = "jdf";
          src = inputs.packages-jdf;
          nativeBuildInputs = [
            (pkgs.writeShellScript "force-tex-output.sh" ''
              out="''${tex-}"
            '')
          ];
          outputs = [ "tex" ];
          dontConfigure = true;

          installPhase = ''
            path="$tex/tex/generic/jdf"
            mkdir -p "$path"
            cp $src/jdf.cls "$path"/jdf.cls
          '';
        };
      in
      [
        (
          with pkgs.texlive;
          combine {
            inherit
              scheme-small
              biblatex
              dvipng
              dvisvgm
              latexmk
              ;
            inherit
              amsmath
              babel
              capt-of
              caption
              changepage
              cm-super
              csquotes
              enumitem
              environ
              etoolbox
              eulervm
              everypage
              float
              footmisc
              footnotebackref
              fvextra
              geometry
              hyperref
              jdf
              ly1
              mathpazo
              mdframed
              microtype
              needspace
              nowidow
              pdfcol
              siunitx
              soul
              sourcecodepro
              standalone
              subfiles
              tcolorbox
              titlesec
              type1cm
              wrapfig
              xcolor
              zref
              ;
          }
        )
      ];
  };
}
