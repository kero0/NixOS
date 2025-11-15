{ myuser, ... }:
{
  my = {
    services.ssh.enable = true;
    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
    };
  };
}
