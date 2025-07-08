{
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernelParams = [
      # serial
      "console=ttyS0,115200n8"
      # HDMI
      "console=tty0"
      # continuous memory allocator, seems recommended for rpi
      "cma=256M"
    ];
    initrd.availableKernelModules = [
      # Allows early (earlier) modesetting for the Raspberry Pi
      "vc4"
      "bcm2835_dma"
      "i2c_bcm2835"
    ];
    consoleLogLevel = 7;
  };

  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 4 * 1024;
    }
  ];

  networking.useDHCP = true;
}
