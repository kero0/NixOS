{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.curl;
in
{
  options.my.home.curl.enable = mkEnableOption "Enable curl";
  config = mkIf cfg.enable {
    home.packages = [ pkgs.curl ];
    xdg.configFile.".curlrc".text = ''
      # max time in seconds to connect
      connect-timeout = 15

      # continue from previous
      continue-at

      # follow redirects
      location
      # set previous URL when following a redirect
      referer = ";auto"

      # display progress
      progress-bar

      # use the server timestamp
      remote-time

      # number of times to retry on failure
      retry = 5

      # Show error messages
      show-error

      # impersonate a browser
      user-agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0"
    '';
  };
}
