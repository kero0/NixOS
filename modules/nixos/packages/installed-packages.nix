{ pkgs, config, lib, ... }:
let cfg = config.my.allpkgs; in
  with lib; {
    options.my.allpkgs.enable = mkEnableOption "Install my desktop apps";
    config = lib.mkIf cfg.enable {
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
  };
}
