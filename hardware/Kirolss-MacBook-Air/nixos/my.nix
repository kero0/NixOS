{ myuser, ... }:
{
  my = {
    allpkgs.enable = true;
    desktop.enable = false;
    fonts.enable = true;
    gaming.enable = false;
    samba.enable = false;
    scripts.enable = false;

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
