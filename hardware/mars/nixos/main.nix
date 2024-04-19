{ pkgs, ... }:
{
  networking.hostName = "mars";

  programs.firejail.enable = true;
  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "daily";
      fileSystems = [
        "/"
        "/home"
      ];
    };
    #     btrbk = {
    #       instances.btrbk = {
    #         settings = {
    #           snapshot_preserve_min = "2d";
    #           snapshot_preserve = "14d";
    #           volume."/run/nixenc".subvolume."home".snapshot_create = "onchange";
    #         };
    #         onCalendar = "daily";
    #       };
    #     };
    fwupd.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  boot = {
    # kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelPackages = pkgs.linuxKernel.packages.linux_testing;
    loader.systemd-boot.enable = true;
    #     resumeDevice = "/swap/swapfile";
  };
  fonts.fontconfig.antialias = true;

  #   swapDevices = [{
  #     device = "/swap/swapfile";
  #     size = 32 * 1024;
  #   }];

  networking.firewall.enable = true;
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "weekly";
    randomizedDelaySec = "45min";
    persistent = true;
    flake = "github:kero0/nixos";
    flags = [ "-L" ];
  };
}
