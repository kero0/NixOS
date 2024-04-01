{ pkgs, lib, ... }:
with pkgs; let
  myscripts = stdenv.mkDerivation {
    name = "my-scripts";
    src = ./.;
    nativeBuildInputs = [ makeWrapper ];
    installPhase = ''
      #NixOS stuff
      makeWrapper $src/delete-old-generations $out/bin/delete-old-generations

      #Others
      makeWrapper $src/getwindowname $out/bin/getwindowname --prefix PATH : ${lib.makeBinPath [ libnotify xorg.xprop ]}
      makeWrapper $src/random-wallpaper $out/bin/random-wallpaper --prefix PATH : ${lib.makeBinPath [ feh ]}
      makeWrapper $src/rofi-ffmpeg-screenshot $out/bin/rofi-ffmpeg-screenshot --prefix PATH : ${lib.makeBinPath [ bash slop ffcast xclip libnotify ffmpeg-full xorg.xwininfo xdg-user-dirs ]}

    '' + lib.strings.optionalString pkgs.stdenv.isLinux "makeWrapper $src/send-remote-audio $out/bin/send-remote-audio --prefix PATH : ${lib.makeBinPath [ ffmpeg pulseaudio ]}";
  };

in
{
  imports = [
    ./monitor-hotplug.nix
  ];
  environment.systemPackages = [
    myscripts
  ];

}
