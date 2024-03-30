{ config, pkgs, ... }: {

  imports = if pkgs.stdenv.isLinux then [
    ./scripts

    ./samba.nix
    ./gaming.nix
  ] else
    [ ];

  environment.systemPackages = with pkgs;
    [
      # Dev stuff
      ghc
      git
      nixfmt
      nixpkgs-fmt
      python3
      rnix-lsp

      # personal stuff
      ## tools
      rsync
      wget
      ## other
      bottom
      comma
    ] ++ (if !stdenv.isDarwin then [
      # browsers
      brave
      google-chrome
      vivaldi

      # bitwarden
      bitwarden
      bitwarden-cli

      # document writing
      xournalpp

      # other
      alacritty
      checkra1n
      mpv
      qalculate-gtk
      scrot
      zathura
    ] else
      [ maccy ]);
}
