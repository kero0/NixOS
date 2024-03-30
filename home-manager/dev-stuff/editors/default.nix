{ config, lib, pkgs, inputs, ... }: {
  programs = {
    emacs = {
      enable = true;
      package = inputs.emacs.packages.${pkgs.system}.default;
    };
    vscode = {
      enable = true;
      package = pkgs.vscode;
    };
  };

  home = let emacs = config.programs.emacs.finalPackage;
  in lib.mkIf config.programs.emacs.enable {
    sessionVariables = {
      EDITOR = "${emacs}/bin/emacsclient -nw -a '${emacs}/bin/emacs'";
      VISUAL = "${emacs}/bin/emacsclient -c -a '${emacs}/bin/emacs'";
    };
    shellAliases.emacs = "${emacs}/bin/emacsclient -nw -a '${emacs}/bin/emacs'";
  };
}
