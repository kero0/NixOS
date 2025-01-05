{
  my.home = {
    applets.enable = false;
    chromium.enable = true;
    clipboard-manager.enable = true;
    downloaders.enable = false;
    editors.enable = true;
    gpg.enable = true;
    notification-manager.enable = false;
    pass.enable = true;
    rofi.enable = true;
    theme = {
      cursor.enable = true;
      enable = true;
    };

    email = {
      enable = true;
      davmail.enable = true;
    };
    hyprland = {
      enable = true;
      binds.enable = true;
      lock.enable = true;
      pyprland.enable = true;
      wallpaper.enable = true;
      waybar.enable = true;
    };
    shell = {
      alias.enable = true;
      bash.enable = true;
      fish.enable = true;
      kitty.enable = true;
      readline.enable = true;
      starship.enable = true;
      zsh.enable = true;

      tools = {
        enable = true;
        atuin.enable = true;
        bat.enable = true;
        nix-index.enable = true;
        ssh.enable = true;
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
