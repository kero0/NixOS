{ myuser, ... }:
{
  system.autoUpgrade.operation = "boot";
  my = {
    autoUpgrade.enable = true;
    desktop.enable = false;
    fonts.enable = true;
    gaming.enable = true;
    samba.enable = false;
    scripts.enable = false;

    services = {
      basic.enable = true;
      ssh.enable = true;
    };

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
      passwordHash = null;
    };
  };
}
