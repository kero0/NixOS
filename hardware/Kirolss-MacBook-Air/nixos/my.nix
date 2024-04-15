{ myuser, ... }:
{
  my = {
    allpkgs.enable = true;
    fonts.enable = true;

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
