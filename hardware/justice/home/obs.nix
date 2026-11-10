{ pkgs, lib, ... }:
let
  inherit (lib) mapAttrsToList mkLuaInline;
in
{
  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      # obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };
  wayland.windowManager.hyprland.settings.bind =

    mapAttrsToList
      (k: v: {
        _args = [
          k
          (mkLuaInline v)
        ];
      })
      {
        "CTRL + F1" = ''hl.dsp.pass({ window = [[class:com\.obsproject\.Studio]] })'';
        "CTRL + F2" = ''hl.dsp.pass({ window = [[class:com\.obsproject\.Studio]] })'';
        "CTRL + F3" = ''hl.dsp.pass({ window = [[class:com\.obsproject\.Studio]] })'';
        "CTRL + F4" = ''hl.dsp.pass({ window = [[class:com\.obsproject\.Studio]] })'';
      };
}
