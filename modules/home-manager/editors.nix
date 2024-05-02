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
      vscode = {
        enable = true;
        package = pkgs.vscode;
      };
    };
    services.emacs = {
      enable = cfg.emacsdaemon;
      package = config.programs.emacs.finalPackage;
      defaultEditor = true;
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
	lib.mkIf config.programs.emacs.enable {
          sessionVariables.VISUAL = "${emacs}/bin/emacsclient -c";
          shellAliases.emacs = config.home.sessionVariables.VISUAL;
	};
  };
}
