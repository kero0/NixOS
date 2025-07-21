{ lib, ... }:
{
  security.sudo.wheelNeedsPassword = false;
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  networking.networkmanager.enable = true;
}
