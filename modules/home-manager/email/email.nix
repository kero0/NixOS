{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.email;
in
{
  options.my.home.email.enable = mkEnableOption "Enable email module";
  # initialize mail
  # mkdir ~/.local/share/mail/{bakheakm-udmercy,kbakheat-gmail,kirolsb5-gmail}
  # mbsync --pull -a
  # mu init --maildir ~/.local/share/mail --my-address kbakheat@gmail.com --my-address kirolsb5@gmail.com --my-address bakheakm@udmercy.edu
  # mu index
  config = mkIf cfg.enable {
    programs = {
      mbsync = {
        enable = true;
        package = pkgs.buildEnv {
          name = "isync-oauth2";
          paths = [ pkgs.isync ];
          pathsToLink = [ "/bin" ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram "$out/bin/mbsync" \
              --prefix SASL_PATH : "${pkgs.cyrus_sasl.out.outPath}/lib/sasl2":"${pkgs.cyrus-sasl-xoauth2.out.outPath}/lib/sasl2"
          '';
        };
      };
      msmtp = {
        enable = true;
        extraAccounts = ''
          auth on
          tls on
          logfile ${config.xdg.cacheHome}/msmtp.log
        '';
      };
      mu.enable = true;
    };

    xsession.importedVariables = [
      "GPG_TTY"
      "GNUPGHOME"
      "PASSWORD_STORE_DIR"
    ];
    services.imapnotify.enable = true;
  };
}
