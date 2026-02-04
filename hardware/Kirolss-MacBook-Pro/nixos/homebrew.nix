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
      "bambu-studio"
      "hammerspoon"
      "maccy"
      "orion"
      "the-unarchiver"
      "unnaturalscrollwheels"
      "vivaldi"
      "vlc"
    ];
  };
  environment.systemPath = [ config.homebrew.brewPrefix ];
}
