{
  config,
  lib,
  options,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.my.boot.esp;

  # sgdisk sizes as disko writes them ("512M", "1G", "+512M"; K/M/G/T/P are binary units) -> MiB
  toMiB =
    s:
    let
      m = builtins.match "\\+?([0-9]+)([KMGTP]?)" s;
      n = lib.toInt (builtins.elemAt m 0);
      unit = builtins.elemAt m 1;
      factor =
        {
          "" = 1.0 / 1024 / 1024; # bytes
          K = 1.0 / 1024;
          M = 1;
          G = 1024;
          T = 1024 * 1024;
          P = 1024 * 1024 * 1024;
        }
        .${unit};
    in
    if m == null then null else n * factor;

  # MiB of a disko gpt partition: `size`, or `end` relative ("+512M") / absolute minus `start`
  partitionMiB =
    p:
    if p.size != "0" && p.size != "100%" then
      toMiB p.size
    else if lib.hasPrefix "+" p.end then
      toMiB p.end
    else
      let
        end = toMiB p.end;
        start = toMiB p.start;
      in
      if end == null || start == null then null else end - start;

  # the EF00 partitions of every disko disk with a gpt table
  diskoEsps = lib.optionals (options ? disko) (
    lib.concatMap (
      disk:
      lib.filter (p: p.type == "EF00") (
        lib.attrValues (if (disk.content.type or null) == "gpt" then disk.content.partitions else { })
      )
    ) (lib.attrValues config.disko.devices.disk)
  );
  diskoEspMiB = if lib.length diskoEsps == 1 then partitionMiB (lib.head diskoEsps) else null;

  # generations that fit in 70 % of the ESP (30 % margin for systemd-boot itself, firmware
  # update capsules and growth), minus the one being installed before the old ones are
  # removed; at least 2 so there is always a fallback
  derivedLimit = lib.max 2 (builtins.floor (cfg.sizeMiB * 0.7 / cfg.generationMiB) - 1);
in
{
  options.my.boot.esp = {
    sizeMiB = mkOption {
      type = types.nullOr types.number;
      default = diskoEspMiB;
      defaultText = lib.literalExpression "the size of the host's single disko EF00 partition, else null";
      description = ''
        ESP size. When set, boot.loader.systemd-boot.configurationLimit (which lanzaboote also
        uses) is derived from it and generationMiB instead of the fixed default of 15.
      '';
    };
    generationMiB = mkOption {
      type = types.number;
      default = 100;
      description = ''
        ESP space of one generation with its own kernel and initrd (every nixpkgs bump makes
        one): the kernel image plus the initrd, both stored once per distinct file by
        systemd-boot and lanzaboote. Measure with
        `du -m /run/current-system/{kernel,initrd}` (follows the links) and round up; the
        default fits a desktop initrd with GPU firmware and initrd Wi-Fi.
      '';
    };
  };

  config = {
    boot.loader.systemd-boot.configurationLimit = lib.mkDefault (
      if cfg.sizeMiB == null then 15 else derivedLimit
    );
    boot.loader.generic-extlinux-compatible.configurationLimit = lib.mkDefault 10;

    nix.settings = {
      min-free = lib.mkDefault (1024 * 1024 * 1024); # 1 GiB
      max-free = lib.mkDefault (5 * 1024 * 1024 * 1024); # 5 GiB
    };
  };
}
