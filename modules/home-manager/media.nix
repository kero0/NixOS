{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.media;
in
{
  options.my.home.media = {
    enable = mkEnableOption "Enable media config";
    musicDirectory = mkOption {
      type = types.str;
      default =
        if config.xdg.userDirs.enable then
          config.xdg.userDirs.music
        else
          "${config.home.homeDirectory}/Music";
    };

  };
  config = mkIf cfg.enable {
    programs = {
      mpv = {
        enable = true;
        package = pkgs.mpv-unwrapped.wrapper {
          mpv = pkgs.mpv-unwrapped.override { vapoursynthSupport = true; };
          scripts =
            with pkgs.mpvScripts;
            [
              mpv-cheatsheet
              mpv-playlistmanager
              mpv-subtitle-lines
              quality-menu
              sponsorblock
              youtube-upnext
            ]
            ++ lists.optionals pkgs.stdenv.isLinux [ mpris ];
          youtubeSupport = true;
        };
      };
      ncmpcpp = {
        enable = true;
        mpdMusicDir = cfg.musicDirectory;
        bindings = [
          {
            key = "j";
            command = "scroll_down";
          }
          {
            key = "k";
            command = "scroll_up";
          }
          {
            key = "J";
            command = [
              "select_item"
              "scroll_down"
            ];
          }
          {
            key = "K";
            command = [
              "select_item"
              "scroll_up"
            ];
          }
        ];
      };
      rmpc.enable = true;
    };
    services = {
      mpd = {
        inherit (cfg) musicDirectory;
        enable = true;
        network.startWhenNeeded = pkgs.stdenv.isLinux;
      };
      mpd-mpris.enable = pkgs.stdenv.isLinux;
      mpris-proxy.enable = pkgs.stdenv.isLinux;
    };
  };
}
