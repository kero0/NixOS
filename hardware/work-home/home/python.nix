{
  programs = {
    poetry = {
      enable = true;
      settings = {
        virtualenvs = {
          in-project = true;
          create = true;
        };
      };
    };
    pyenv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
