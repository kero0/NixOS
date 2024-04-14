{ pkgs, lib, ... }:
with pkgs; let
  myscripts = stdenv.mkDerivation {
    name = "my-scripts";
    src = ./.;
    nativeBuildInputs = [ makeWrapper ];
    installPhase = ''
      #NixOS stuff
      makeWrapper $src/delete-old-generations $out/bin/delete-old-generations
    '' + lib.strings.optionalString pkgs.stdenv.isLinux "makeWrapper $src/send-remote-audio $out/bin/send-remote-audio --prefix PATH : ${lib.makeBinPath [ ffmpeg pulseaudio ]}";
  };
in
  { environment.systemPackages = [ myscripts ]; }
