{
  config,
  pkgs,
  lib,
  ...
}:
{
  security.sudo.wheelNeedsPassword = false;
  hardware = {
    steam-hardware.enable = true;
    graphics.enable32Bit = true;
  };
  services = {
    xserver.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        settings.General.DisplayServer = "wayland";
      };
      autoLogin = {
        enable = true;
        user = config.my.user.username;
      };
    };
  };
  users.users.${config.my.user.username}.password = "";
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      package = lib.mkForce (
        pkgs.steam.override {
          extraLibraries = pkgs: [ pkgs.gperftools ];
          extraPkgs =
            p: with p; [
              libxcursor
              libxi
              libxinerama
              libxscrnsaver
              libpng
              libpulseaudio
              libvorbis
              stdenv.cc.cc.lib
              libkrb5
              keyutils
            ];
        }
      );
    };
    gamemode.enable = true;
  };
  environment.systemPackages = with pkgs; [
    steamcmd
    steam-run
    protonup-qt
  ];
}
