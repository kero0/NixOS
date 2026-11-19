{ myuser, ... }:
{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  my = {
    boot.esp.generationMiB = 85;
    # FIDO2 if plugged in, then {tang+TPM2 at home | ssh | keyboard}: docs/disk-unlock.md
    diskUnlock = {
      enable = false;
      # sss t=2 over tpm2 (PCR 7: lanzaboote's secure-boot state) + tang
      tang = {
        enable = true;
        tpm2.enable = true;
      };
      ssh.enable = true;
      # no RJ45 on the L13 Yoga: USB / USB-C ethernet adapters and docks (inferred; check with
      # `readlink /sys/class/net/<if>/device/driver`)
      network.kernelModules = [
        "r8152"
        "cdc_ether"
        "cdc_ncm"
        "ax88179_178a"
      ];
      # Intel CNVi Wi-Fi (iwlwifi, the module default); interface name inferred, check `ip link`
      wifi = {
        enable = true;
        interface = "wlp0s20f3";
      };
    };
    desktop.enable = true;
    fonts.enable = true;
    gaming.enable = true;
    laptop.enable = true;
    samba.enable = true;
    scripts.enable = true;
    virtualization.enable = true;

    services = {
      basic.enable = true;
      ssh.enable = true;
    };

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
