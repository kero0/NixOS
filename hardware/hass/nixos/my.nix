{ myuser, ... }:
{
  my = {

    boot.esp.generationMiB = 70;
    autoUpgrade = {
      enable = true;
      allowReboot = true;
    };
    diskUnlock = {
      enable = true;
      tang.enable = true;
      ssh.enable = true;
      network.kernelModules = [ "igc" ];
    };
    desktop.enable = false;
    fonts.enable = false;
    gaming.enable = false;
    samba.enable = false;
    scripts.enable = false;
    server.enable = true;

    services = {
      adguardserver = {
        enable = true;
        openPorts = true;
      };
      basic.enable = false;
      ssh.enable = true;
    };

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
