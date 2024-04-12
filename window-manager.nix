{ myuser, ... }: {
  programs = {
    hyprland.enable = true;
    seahorse.enable = true;
  };
  security.pam.services = {
    hyprlock = { };
    ${myuser}.enableGnomeKeyring = true;
  };
  services = {
    devmon.enable = true;
    gnome.gnome-keyring.enable = true;
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
        defaultSession = "hyprland";
      };
    };
  };
}
