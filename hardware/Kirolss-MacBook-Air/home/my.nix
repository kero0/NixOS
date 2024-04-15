{
  my.home = {
    applets.enable = false;
    chromium.enable = true;
    clipboard-manager.enable = false;
    downloaders.enable = true;
    email.enable = true;
    gpg.enable = true;
    notification-manager.enable = false;
    pass.enable = true;
    rofi.enable = false;

    editors = {
      enable = true;
      emacsdaemon = false;
    };
    hyprland = {
      enable = false;
      binds.enable = false;
      lock.enable = false;
      pyprland.enable = false;
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
        ssh.enable = true;
        tealdeer.enable = true;

        git = {
          enable = true;
          userName = "kero0";
          userEmail = "kbakheat@gmail.com";
        };
      };
    };
  };
}
