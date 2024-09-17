{
  my.home = {
    applets.enable = false;
    chromium.enable = true;
    clipboard-manager.enable = true;
    downloaders.enable = false;
    gpg.enable = true;
    notification-manager.enable = false;
    pass.enable = true;
    rofi.enable = true;
    theme = {
      cursor.enable = true;
      enable = true;
    };

    editors = {
      enable = true;
      emacsdaemon = true;
    };
    email = {
      enable = false;
      davmail.enable = false;
    };
    hyprland = {
      enable = true;
      binds.enable = false;
      lock.enable = false;
      pyprland.enable = false;
      wallpaper.enable = false;
      waybar.enable = false;
    };
    shell = {
      alias.enable = true;
      fish.enable = true;
      kitty.enable = true;
      starship.enable = true;
      zsh.enable = true;

      tools = {
        enable = true;
        atuin.enable = true;
        bat.enable = true;
        nix-index.enable = true;
        ssh.enable = false;
        tealdeer.enable = true;
        tmux.enable = true;
        zoxide.enable = true;

        git = {
          enable = true;
          userName = "kbakheat_ford";
          userEmail = "kbakheat@ford.com";
        };
      };
    };
  };
}
