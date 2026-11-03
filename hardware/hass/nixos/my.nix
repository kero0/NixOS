{ myuser, ... }:
{
  my = {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
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
