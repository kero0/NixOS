{ pkgs, ... }:
{
  time.timeZone = "America/Detroit";
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_hardened;
    loader.systemd-boot.enable = true;
  };
  networking.networkmanager.enable = true;
}
