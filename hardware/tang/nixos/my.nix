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

    services = {
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
