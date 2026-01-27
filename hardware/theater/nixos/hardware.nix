{
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  time.timeZone = "America/Detroit";
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "vmd"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod;
    loader.systemd-boot.enable = true;
  };
  hardware = {
    # BT
    bluetooth.enable = true;
    # CPU
    cpu.intel.updateMicrocode = true;
    # Sensors
    sensor.iio.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };
  networking.networkmanager.enable = true;
}
