{
  targets.genericLinux.enable = true;
  programs.git = {
    lfs.enable = true;
    settings = {
      github.user = "kero0";
      user.signingKey = "6203EA1E2A444A37709BF65023B20E88C6992499";
      push.autoSetupRemote = true;
    };
  };
}
