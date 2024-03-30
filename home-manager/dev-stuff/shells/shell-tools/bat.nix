{ pkgs, ... }: {
  programs.bat = {
    enable = true;
    config.theme = if pkgs.stdenv.isDarwin then "OneHalfLight" else "Dracula";
    extraPackages = with pkgs.bat-extras; [ batwatch ];
  };
}
