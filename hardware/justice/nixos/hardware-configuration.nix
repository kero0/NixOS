{ lib, config, ... }:
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  # boot.initrd.luks.devices."crypted".device =
  #   "/dev/disk/by-uuid/75e50b04-db47-4936-b278-3c520f6c918a";

  # fileSystems = {
  #   "/" = {
  #     device = "/dev/mapper/crypted";
  #     fsType = "btrfs";
  #     options = [ "subvol=root" ];
  #   };

  #   "/nix" = {
  #     device = "/dev/mapper/crypted";
  #     fsType = "btrfs";
  #     options = [ "subvol=nix" ];
  #   };

  #   "/.swapvol" = {
  #     device = "/dev/mapper/crypted";
  #     fsType = "btrfs";
  #     options = [ "subvol=swap" ];
  #   };

  #   "/home" = {
  #     device = "/dev/mapper/crypted";
  #     fsType = "btrfs";
  #     options = [ "subvol=home" ];
  #   };

  #   "/boot" = {
  #     device = "/dev/disk/by-uuid/F8E0-07F0";
  #     fsType = "vfat";
  #     options = [
  #       "fmask=0077"
  #       "dmask=0077"
  #     ];
  #   };
  # };
  boot.kernelModules = [ "kvm-intel" ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
