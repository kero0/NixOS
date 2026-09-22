{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.ssh;
in
{
  options.my.home.ssh.enable = mkEnableOption "Enable ssh config";
  config = mkIf cfg.enable {
    xdg.dataFile."ssh-control/.keep" = {
      enable = true;
      text = "";
    };
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = rec {
        "*github*" = {
          ControlPersist = "no";
          ControlMaster = "no";
        };
        hass = {
          port = 9639;
          hostname = "hass.localdomain";
          user = "kirolsb";
        };
        backy = {
          port = 9639;
          hostname = "209.209.10.60";
          user = "kirolsb";
        };
        hass-bash = hass // {
          RemoteCommand = "bash -l";
          RequestTTY = "force";
        };
        installer = {
          port = 9639;
          hostname = "nixos-installer.localdomain";
          user = "kirolsb";
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
        nasy = {
          port = 9639;
          hostname = "nasy.localdomain";
          user = "kirolsb";
        };
        nasy-bash = nasy // {
          RemoteCommand = "bash -l";
          RequestTTY = "force";
        };
        opnsense = {
          port = 22;
          hostname = "opnsense.localdomain";
          user = "admin";
        };
        tang = {
          port = 9639;
          hostname = "tang.localdomain";
          user = "kirolsb";
        };
        theater = {
          port = 9639;
          hostname = "theater.localdomain";
          user = "kirolsb";
        };
        macbook = {
          port = 22;
          hostname = "mac.localdomain";
          user = "kirolsbakheat";
        };
        justice = {
          port = 9639;
          hostname = "justice.localdomain";
          user = "kirolsb";
        };
        xps = {
          port = 9639;
          hostname = "Kirols-xps9575.localdomain";
          user = "kirolsb";
        };
        "*" = {
          controlMaster = "auto";
          controlPersist = "yes";
          controlPath = "${config.xdg.dataHome}/ssh-control/%C";
        };
      };
      includes = [
        "config.d/*"
        config.age.secrets.ssh-config-private.path
      ];
    };
  };
}
