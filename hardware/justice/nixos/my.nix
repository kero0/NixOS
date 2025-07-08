{ myuser, ... }:
{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  my = {
    allpkgs.enable = true;
    desktop.enable = true;
    fonts.enable = true;
    gaming.enable = true;
    samba.enable = true;
    scripts.enable = true;
    virtualization.enable = true;

    services = {
      basic.enable = true;
      ssh.enable = true;
    };

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
