{
  imports = [
    ./aliases.nix
  ];

  xresources = {
    properties = {
      "*.dpi" = 192;
      "Xft.dpi" = 192;
    };
  };
}
