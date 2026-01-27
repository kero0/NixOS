{
  config,
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
    greedyCasks = true;
    casks = [
      "appcleaner"
      "bambu-studio"
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
