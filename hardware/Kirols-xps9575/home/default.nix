{
  imports = [
    ./aliases.nix
    ./kanshi.nix
  ];

  programs.git.extraConfig.user.signingKey = "9E8CA5ADA77C3B787B4D3A294D004B9A43E3108F";

  xresources = {
    properties = {
      "*.dpi" = 192;
      "Xft.dpi" = 192;
    };
  };
}
