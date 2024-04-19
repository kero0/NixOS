{
# Minimal list of modules to use the EFI system partition and the YubiKey
boot.initrd.kernelModules = [ "vfat" "nls_cp437" "nls_iso8859-1" "usbhid" ];

# Enable support for the YubiKey PBA
boot.initrd.luks.yubikeySupport = true;

# Configuration to use your Luks device
boot.initrd.luks.devices = {
  "nixos-enc" = {
    device = "/dev/nvme0n1p2";
    preLVM = true; # You may want to set this to false if you need to start a network service first
    yubikey = {
      slot = 2;
      twoFactor = false; # Set to false if you did not set up a user password.
      storage = {
        device = "/dev/nvme0n1p1";
      };
    };
  }; 
};
}
