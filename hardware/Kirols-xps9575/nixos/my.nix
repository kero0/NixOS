{ myuser, ... }:
{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  my = {
    boot.esp.generationMiB = 110;
    diskUnlock = {
      enable = true;
      tang.enable = true;
      ssh.enable = true;
      network.kernelModules = [
        "r8152"
        "cdc_ether"
        "cdc_ncm"
        "ax88179_178a"
      ];
      wifi = {
        enable = true;
        interface = "wlp2s0";
        kernelModules = [ "ath10k_pci" ];
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
