{ pkgs, ... }:
{
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
    resumeDevice = "/.swapvol/swapfile";
  };

  swapDevices = [
    {
      device = "/.swapvol/swapfile";
      size = 32 * 1024;
    }
  ];

  networking.firewall.enable = true;

  environment.systemPackages = with pkgs; [ pciutils ];
}
