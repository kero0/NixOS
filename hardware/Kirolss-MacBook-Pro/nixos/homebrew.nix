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
      "google-chrome"
      "hammerspoon"
      "maccy"
      "the-unarchiver"
      "unnaturalscrollwheels"
      "vivaldi"
      "vlc"
    ];
  };
  environment.systemPath = [ "${config.homebrew.prefix}/bin" ];
}
