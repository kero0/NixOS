{ pkgs, ... }: {
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "kero0";
    userEmail = "kbakheat@gmail.com";
    includes = [
      {
        condition = "gitdir:~/seniordesign";
        contents = {
          user = {
            name = "KirolsAtSchool";
            email = "bakheakm@udmercy.edu";
          };
        };
      }
    ];
  };
}
