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
      "maccy"
      "nordvpn"
      "orion"
      "the-unarchiver"
      "unnaturalscrollwheels"
      "vivaldi"
      "vlc"
      "wine@staging"
      "zen"
    ];
  };
  environment.systemPath = [ config.homebrew.brewPrefix ];
}
