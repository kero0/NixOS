{ ... }: {
  programs.ssh = {
    enable = true;
    matchBlocks.nasy = {
      port = 9639;
      hostname =  "nasy.local";
      user = "kirolsb";
    };
  };
}
