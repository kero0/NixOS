{
  pkgs,
  lib,
  osconfig,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.my.home.editors;
in
{
  options.my.home.editors = {
    enable = mkEnableOption "Enable editors config";
    emacsdaemon = mkEnableOption "Enable emacs daemon";
  };
  config = mkIf cfg.enable {
    programs = {
      emacs = {
        enable = true;
        package = inputs.emacs.packages.${pkgs.system}.default;
      };
      vim.enable = true;
    };
    services.emacs = {
      enable = cfg.emacsdaemon;
      package = config.programs.emacs.finalPackage;
      defaultEditor = false;
      client = {
        enable = true;
        arguments = [
          "-c"
          "-a"
        ];
      };
    };

    home =
      let
        emacs = config.programs.emacs.finalPackage;
      in
      lib.mkIf cfg.emacsdaemon {
        sessionVariables.EDITOR =
          pkgs.writeShellScriptBin "editor" ''${emacs}/bin/emacsclient -nw "$@" '' + /bin/editor;
        sessionVariables.VISUAL =
          pkgs.writeShellScriptBin "visual" ''${emacs}/bin/emacsclient -c "$@" '' + /bin/visual;
        shellAliases.emacs = config.home.sessionVariables.VISUAL;
      };
  };
}
