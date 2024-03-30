{ pkgs, config, ... }: {
  imports = [ ./atuin.nix ./bat.nix ./git.nix ./tealdeer.nix ];
  programs = {
    command-not-found.enable = false;
    eza.enable = true;
    feh.enable = pkgs.lib.mkIf pkgs.stdenv.isLinux true;
    jq.enable = true;
    man.enable = true;
    nix-index.enable = false;
    zathura.enable = pkgs.lib.mkIf pkgs.stdenv.isLinux true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
