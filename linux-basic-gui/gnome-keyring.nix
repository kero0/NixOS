{ pkgs, myuser, ... }: {
  security.pam.services.${myuser}.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
}
