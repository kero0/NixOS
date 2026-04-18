{
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    rclone.enable = true;
  };
  home.packages = with pkgs; [
    inputs.coptic-font-conversion.packages.${stdenv.system}.default

    file
    lsof
    pciutils
    rsync
    usbutils
    wget
  ];
}
