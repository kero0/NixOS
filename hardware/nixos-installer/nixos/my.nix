{ myuser, ... }:
{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  my = {
    services.ssh.enable = true;
    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
