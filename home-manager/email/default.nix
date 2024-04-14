{ config, lib, pkgs, homedir, ... }: {
  imports = [ ./accounts.nix ];
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
            --prefix SASL_PATH : "${pkgs.cyrus_sasl.out.outPath}/lib/sasl2":"${pkgs.cyrus_sasl_xoauth2.out.outPath}/lib/sasl2"
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
    offlineimap = {
      enable = false;
      pythonFile = ''
        #!${pkgs.python3}/bin/python
        import subprocess
        import json

        def get_pass(service, cmd):
          return subprocess.check_output(cmd, )

        def get_udmercy_token():
            proc = subprocess.run(
                [
                  'gpg2',
                  '--decrypt' ,
                  '${config.programs.password-store.settings.PASSWORD_STORE_DIR}/office.com/bakheakm@udmercy.edu.tokens'
                ],
                capture_output=True,
            )
            data = json.loads(proc.stdout)
            return data['access_token']
      '';
    };
  };

  xsession.importedVariables = [ "PASSWORD_STORE_DIR" ];
  services.imapnotify.enable = true;
}
