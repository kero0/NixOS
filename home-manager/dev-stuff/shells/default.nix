{ pkgs, ... }: {
  imports = [
    ./kitty.nix

    ./starship.nix

    ./aliases.nix
    ./fish.nix
    ./zsh.nix

    ./shell-tools
  ];
  services.lorri.enable = pkgs.lib.mkIf pkgs.stdenv.isLinux true;
}
