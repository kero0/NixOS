{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.scripts;
in
with lib;
{
  options.my.scripts.enable = mkEnableOption "Install assorted scripts";
  config = lib.mkIf cfg.enable (
    with pkgs;
    let
      myscripts = stdenv.mkDerivation {
        name = "my-scripts";
        src = ./.;
        nativeBuildInputs = [ makeWrapper ];
        installPhase =
          ''
            #NixOS stuff
            makeWrapper $src/delete-old-generations $out/bin/delete-old-generations
          ''
          + lib.strings.optionalString pkgs.stdenv.isLinux "makeWrapper $src/send-remote-audio $out/bin/send-remote-audio --prefix PATH : ${
            lib.makeBinPath [
              ffmpeg
              pulseaudio
            ]
          }";
      };
    in
    {
      environment.systemPackages = [ myscripts ];
    }
  );
}
