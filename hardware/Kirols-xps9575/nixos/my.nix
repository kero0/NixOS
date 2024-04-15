{ myuser, ... }:
{
  my = {
    allpkgs.enable = true;
    desktop.enable = true;
    fonts.enable = true;
    gaming.enable = true;
    samba.enable = true;
    scripts.enable = true;

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
