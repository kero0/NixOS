{ pkgs, ... }: {
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs;[
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
}
