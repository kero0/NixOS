{ config, pkgs, ... }:
{
  # Minimal list of modules to use the EFI system partition and the YubiKey
  boot.initrd.kernelModules = [
    "vfat"
    "nls_cp437"
    "nls_iso8859-1"
    "usbhid"
  ];

  # Configuration to use your Luks device
  boot.initrd.luks.devices = {
    "nixos-enc" = {
      device = "/dev/nvme0n1p2";
      preLVM = true; # You may want to set this to false if you need to start a network service first
    };
  };
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  };
  users.users.${config.my.user.username}.extraGroups = [ "tss" ]; # tss group has access to TPM devices
  boot.initrd.systemd = {
    enable = true;
    enableTpm2 = true;
  };
  environment.systemPackages = with pkgs; [ tpm2-tss ];
}
