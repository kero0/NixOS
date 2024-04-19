{
  my.home = {
    downloaders.enable = true;
    email.enable = true;
    gpg.enable = true;
    pass.enable = true;

    editors = {
      enable = true;
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
