{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.downloaders;
in
{
  options.my.home.downloaders.enable = mkEnableOption "Enable downloaders";
  config = mkIf cfg.enable {
    programs = {
      gallery-dl.enable = true;

      yt-dlp = {
        enable = true;
        settings = {
          cookies-from-browser = "vivaldi";
          format = "bestvideo[height<=?1080]+bestaudio/best[height<=?1080]";
          output = "./%(title)s-%(uploader|)s.%(ext)s";
          sub-langs = "en.*";
        };
        extraConfig = ''
          --restrict-filenames

          --embed-chapters
          --embed-metadata
          --embed-subs
          --embed-thumbnail
        '';
      };
    };
  };
}
