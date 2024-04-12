{ pkgs, config, ... }: {
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "kero0";
    userEmail = "kbakheat@gmail.com";
    ignores = [
      "result"
      ".DS_STORE"
    ];
    extraConfig = {
      commit.gpgSign = true;
      init.defaultBranch = "main";
    };
  };
}
