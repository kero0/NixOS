{ myuser, config, ... }:
{
  age.identityPaths = [ "${config.my.user.homedir}/.ssh/id_ed25519" ];
  system.primaryUser = config.my.user.username;
  my = {
    allpkgs.enable = true;
    fonts.enable = true;

    services = {
      ssh.enable = true;
    };

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
