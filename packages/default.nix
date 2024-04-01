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
      git
      python3

      # personal stuff
      ## tools
      rsync
      wget
      ## other
      bottom
      comma
    ] ++ (if !stdenv.isDarwin then [
      # browsers
      google-chrome

      # bitwarden
      bitwarden
      bitwarden-cli

      # document writing
      xournalpp

      # other
      alacritty
      mpv
      qalculate-gtk
      scrot
      zathura
    ] else
      [ maccy ]);
}
