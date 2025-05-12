{
  pkgs,
  lib,
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
      enable = true;
      client.enable = true;
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
        shellAliases.emacs = config.home.sessionVariables.VISUAL;
      };
  };
}
