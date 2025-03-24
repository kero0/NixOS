{ pkgs, ... }:
{
  networking.hostName = "Kirols-xps9575";

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "daily";
      fileSystems = [
        "/"
        "/home"
      ];
    };
    btrbk = {
      instances.btrbk = {
        settings = {
          snapshot_preserve_min = "2d";
          snapshot_preserve = "14d";
          volume."/run/nixenc".subvolume."home".snapshot_create = "onchange";
        };
        onCalendar = "daily";
      };
    };
    fwupd.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    loader.systemd-boot.enable = true;
    resumeDevice = "/swapfile";
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32 * 1024;
    }
  ];

  networking.firewall.enable = true;
}
