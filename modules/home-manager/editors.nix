{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.home.editors;
  emacs = inputs.emacs.packages.${pkgs.stdenv.hostPlatform.system}.mkEmacs {
    patches = cfg.emacsPatches;
  };
in
{
  options.my.home.editors = {
    enable = mkEnableOption "Enable editors config";
    emacsPatches = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Patches to the emacs config for this machine.";
    };
  };
  config = mkIf cfg.enable {
    programs = {
      emacs = {
        enable = true;
        package = emacs;
      };
      vim.enable = true;
    };
    services.emacs = {
      enable = true;
      client.enable = true;
      package = emacs;
    };

    home =
      let
        emacs = config.programs.emacs.finalPackage;
      in
      {
        sessionVariables = {
          ALTERNATE_EDITOR = "";
          EDITOR = pkgs.writeShellScriptBin "editor" ''${emacs}/bin/emacsclient -nw "$@" '' + /bin/editor;
          VISUAL = pkgs.writeShellScriptBin "visual" ''${emacs}/bin/emacsclient -c "$@" '' + /bin/visual;
        };
        shellAliases = {
          emacs = config.home.sessionVariables.VISUAL;
          e = config.home.sessionVariables.EDITOR;
          v = config.home.sessionVariables.VISUAL;
        };
      };
  };
}
