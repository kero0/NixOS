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
      "displaylink"
      "hammerspoon"
      "maccy"
      "microsoft-remote-desktop"
      "nordvpn"
      "orion"
      "the-unarchiver"
      "unnaturalscrollwheels"
      "vivaldi"
      "vlc"
      "wine@staging"
    ];
  };
  environment.systemPath = [ config.homebrew.brewPrefix ];
}
