{ myuser, ... }:
{
  my = {
    desktop.enable = false;
    fonts.enable = false;
    gaming.enable = false;
    samba.enable = false;
    scripts.enable = false;

    services = {
      adguardserver.enable = true;
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
