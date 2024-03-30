{ config, lib, pkgs, modulesPath, myuser, ... }: {
  imports = [
    ./window-managers

    ./gnome-keyring.nix
  ];

  services = {
    devmon.enable = true;
    greenclip.enable = true;
    udisks2.enable = true;

    xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      xkb.layout = "us";
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
        autoLogin = {
          enable = false;
          user = myuser;
        };
        defaultSession = "sway";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    dmenu
    ranger
    gnome.nautilus
    xdotool
  ];

  # qt = {
  #   enable = true;
  #   style = "Nordic-darker";
  # };

  programs.file-roller.enable = true;

}
