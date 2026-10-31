{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.my.home;
  rebuildScript = pkgs.writeShellScriptBin "rebuild" (
    if osConfig == null then
      ''
        ${lib.getExe config.programs.nh.package} home switch ${cfg.configDir} --show-trace
      ''

    else if pkgs.stdenv.hostPlatform.isLinux then
      ''
        ${lib.getExe config.programs.nh.package} os switch ${cfg.configDir} --show-trace
      ''
    else if pkgs.stdenv.hostPlatform.isDarwin then
      ''
        ${lib.getExe config.programs.nh.package} darwin switch ${cfg.configDir} --show-trace
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
          "${cfg.homedir}/.config/nixos"
        else if pkgs.stdenv.hostPlatform.isLinux then
          "${cfg.homedir}/.config/nixos"
        else if pkgs.stdenv.hostPlatform.isDarwin then
          "${cfg.homedir}/.config/darwin"
        else
          (throw "Unsupported OS: ${osConfig.name or "unknown"}");
    };
  };

  config = {
    home.stateVersion = "22.05";

    home = {
      inherit (cfg) username;
      homeDirectory = lib.mkIf pkgs.stdenv.hostPlatform.isLinux cfg.homedir;
      packages = [
        rebuildScript
        pkgs.age
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

    fonts.fontconfig.enable = true;

    programs = {
      nh = {
        enable = true;
        flake = cfg.configDir;
        clean = mkIf (osConfig == null) {
          enable = true;
          extraArgs = [
            "--keep-since"
            "14d"
            "--keep"
            "3"
          ];
        };
      };

      man.generateCaches = true;

      home-manager = {
        enable = true;
        path = lib.mkForce (cfg.homedir + "/.config");
      };
    };
    xdg.enable = true;
    assertions = [
      {
        assertion = config.warnings == [ ];
        message = "Build aborted due to warnings:\n\t" + (lib.concatStringsSep "\n\t" config.warnings);
      }
    ];
  };
}
