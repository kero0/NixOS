{
  lib,
  pkgs,
  inputs,
  ...
}:
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
  # install a host from its disko layout in one step, e.g.
  #   sudo disko-install --flake github:kero0/nixos#justice --disk main /dev/nvme0n1
  environment.systemPackages = with inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}; [
    disko
    disko-install
    pkgs.git
  ];
  boot.zfs.forceImportRoot = false;
}
