{
  config,
  lib,
  pkgs,
  ...
}:
{
  homebrew = {
    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    casks = [
      "appcleaner"
      "disk-inventory-x"
      "hammerspoon"
      "microsoft-remote-desktop"
      "nordvpn"
      "orion"
      "the-unarchiver"
      "vivaldi"
      "vlc"
      "wine@staging"
    ];
  };
  environment.systemPath = [ config.homebrew.brewPrefix ];
}
