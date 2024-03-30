{ config, lib, pkgs, ... }: {
  homebrew = {
    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [ "homebrew/cask" "homebrew/cask-versions" "homebrew/core" ];
    casks = [
      "appcleaner"
      "disk-inventory-x"
      "displaylink"
      "hammerspoon"
      "microsoft-remote-desktop"
      "nordvpn"
      "the-unarchiver"
      "vivaldi"
      "vlc"
      "wine-staging"
    ];
  };
  environment.systemPath = [ config.homebrew.brewPrefix ];
}
