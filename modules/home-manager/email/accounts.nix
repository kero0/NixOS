{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  maildir = "${config.xdg.dataHome}/mail";
  name = osConfig.my.user.realName or "Kirols Bakheat";
  passwordEval = file: [
    "${./mutt_oauth2.py}"
    "${config.programs.password-store.settings.PASSWORD_STORE_DIR}/${file}"
  ];
  memail =
    {
      email,
      flavor,
      dir,
      oauth,
    }:
    {
      inherit flavor;
      address = email;
      userName = email;
      realName = name;
      mbsync = {
        inherit (config.programs.mbsync) enable;
        create = "both";
        expunge = "both";
        extraConfig = {
          account = {
            AuthMechs = if oauth then "XOAUTH2" else "LOGIN";
          };
          channel = {
            Create = "Both";
            CopyArrivalDate = "yes";
            MaxMessages = 20000;
            Sync = "All";
          };
        };
      };
      imapnotify = {
        inherit (config.services.imapnotify) enable;
        boxes = [ "INBOX" ];
        extraConfig = {
          wait = 5;
          xoauth2 = oauth;
        };
        onNotify =
          let
            mbsync = "${config.programs.mbsync.package}/bin/mbsync ${dir}";
            offlineimap = "${config.programs.offlineimap.package}/bin/offlineimap";
          in
          lib.concatStringsSep " && " (
            (lib.lists.optional config.programs.mbsync.enable mbsync)
            ++ (lib.lists.optional config.programs.offlineimap.enable offlineimap)
          );
        onNotifyPost =
          let
            mu = "${pkgs.mu}/bin/mu index";
            notmuch = "${config.programs.notmuch.package}/bin/notmuch new";
            notify = "${pkgs.libnotify}/bin/notify-send 'New mail for ${email}'";
          in
          lib.concatStringsSep " && " (
            (lib.lists.optional config.programs.notmuch.enable notmuch)
            ++ (lib.lists.optional config.programs.mu.enable mu)
            ++ (lib.lists.optional config.services.swayosd.enable notify)
          );
      };
      msmtp = {
        inherit (config.programs.msmtp) enable;
        extraConfig = {
          auth = if oauth then "xoauth2" else "login";
          logfile = "${config.xdg.cacheHome}/msmtp.log";
        };
      };
      mu.enable = config.programs.mu.enable;
    };
  mgmail =
    {
      email,
      dir,
    }:
    (
      memail {
        email = "${email}@gmail.com";
        flavor = "gmail.com";
        oauth = true;
        inherit dir;
      }
      // {
        passwordCommand = passwordEval "google.com/${dir}.tokens";
      }
    );
in
{
  accounts.email = {
    maildirBasePath = maildir;
    accounts = {
      kbakheat-gmail =
        mgmail {
          email = "kbakheat";
          dir = "kbakheat-gmail";
        }
        // {
          primary = true;
        };
      kirolsb5-gmail = mgmail {
        email = "kirolsb5";
        dir = "kirolsb5-gmail";
      };
      kbakheat3-gatech =
        memail {
          email = "kbakheat3@gatech.edu";
          flavor = "outlook.office365.com";
          dir = "kbakheat3-gatech";
          oauth = true;
        }
        // {
          passwordCommand = passwordEval "office.com/kbakheat3-gatech.tokens";
        };
    };
  };
  systemd.user.services = lib.mkIf (pkgs.stdenv.isLinux && config.services.imapnotify.enable) (
    builtins.foldl'
      (
        acc: f:
        acc
        // {
          "imapnotify-${f}".Unit = {
            After = [
              "network.target"
              "graphical.target"
            ];
            Requires = [ "gpg-agent.service" ];
          };
        }
      )
      { }
      [
        "kbakheat-gmail"
        "kirolsb5-gmail"
        "kbakheat3-gatech"
      ]
  );
}
