{ config, lib, ... }:
{
  security.pam.services.sshd = lib.mkIf config.my.services.ssh.enable {
    fprintAuth = false;
    u2fAuth = false;
  };
}
