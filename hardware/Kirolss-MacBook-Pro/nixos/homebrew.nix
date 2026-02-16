{
  config,
  ...
}:
{
  homebrew = {
    enable = true;
    prefix = "/opt/homebrew";
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
  environment.systemPath = [ "${config.homebrew.prefix}/bin" ];
}
