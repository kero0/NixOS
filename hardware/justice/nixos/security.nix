{ config, ... }:
{
  services.fprintd.enable = true;
  security = {
    pam.u2f = {
      enable = true;
      settings.cue = true;
    };
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };
  users.users.${config.my.user.username}.extraGroups = [ "tss" ];
}
