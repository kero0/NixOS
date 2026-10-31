{ lib, ... }:
{
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 15;
  boot.loader.generic-extlinux-compatible.configurationLimit = lib.mkDefault 10;

  nix.settings = {
    min-free = lib.mkDefault (1024 * 1024 * 1024); # 1 GiB
    max-free = lib.mkDefault (5 * 1024 * 1024 * 1024); # 5 GiB
  };
}
