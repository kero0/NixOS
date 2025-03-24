{ myuser, config, ... }:
{
  age.identityPaths = [ "${config.my.user.homedir}/.ssh/id_ed25519" ];
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
