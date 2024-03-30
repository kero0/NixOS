{
  imports = [ ./qtile.nix ./sway.nix ./xmonad.nix ];
  services.xserver.desktopManager.gnome.enable = true;
}
