{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.my.home;
  rebuildScript = pkgs.writeShellScriptBin "rebuild" (
    if osConfig == null then
      ''
        ${pkgs.nh}/bin/nh home switch ${cfg.configDir}
      ''

    else if pkgs.stdenv.isLinux then
      ''
        ${pkgs.nh}/bin/nh os switch ${cfg.configDir}
      ''
    else if pkgs.stdenv.isDarwin then
      ''
        ${pkgs.nh}/bin/nh darwin switch ${cfg.configDir}
      ''
    else
      ''
        echo "Unsupported OS: ${osConfig.name or "unknown"}"
        exit 1
      ''
  );
in
{
  options.my.home = {
    username = mkOption {
      type = types.str;
      default = osConfig.my.user.username or (throw "Username unset");
    };

    homedir = mkOption {
      type = types.str;
      default = osConfig.my.user.homedir or (throw "Homedir unset");
    };

    configDir = mkOption {
      type = types.str;
      default =
        if osConfig == null then
          "${cfg.homedir}/.config/home-manager"
        else if pkgs.stdenv.isLinux then
          "${cfg.homedir}/.config/nixos"
        else if pkgs.stdenv.isDarwin then
          "${cfg.homedir}/.config/darwin"
        else
          (throw "Unsupported OS: ${osConfig.name or "unknown"}");
    };
  };

  config = {
    home.stateVersion = "22.05";

    home = {
      inherit (cfg) username;
      homeDirectory = lib.mkIf pkgs.stdenv.isLinux cfg.homedir;
      packages = [
        rebuildScript
        pkgs.nh
      ];
    };

    fonts.fontconfig.enable = true;

    programs.home-manager = {
      enable = true;
      path = lib.mkForce (cfg.homedir + "/.config");
    };
    xdg.enable = true;
  };
}
