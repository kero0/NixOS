{ myuser, config, ... }:
{
  age.identityPaths = [ "${config.my.user.homedir}/.ssh/id_ed25519" ];
  my = {
    allpkgs.enable = true;
    desktop.enable = true;
    fonts.enable = true;
    gaming.enable = true;
    samba.enable = true;
    scripts.enable = true;
    virtualization.enable = true;

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
