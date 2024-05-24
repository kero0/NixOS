{
  pkgs,
  lib,
  osconfig,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.theme;
in
{
  options.my.home.theme = {
    enable = mkEnableOption "Variation of catppuccin";
    name = mkOption {
      type = types.str;
      default = "catppuccin";
    };

    accent = mkOption {
      type = types.str;
      default = "lavender";
    };

    flavour = mkOption {
      type = types.str;
      default = "latte";
    };
  };
  config = mkIf cfg.enable {

    catppuccin = {
      inherit (cfg) enable flavour accent;
    };
    programs.swaylock.catppuccin.enable = lib.mkForce false; # broken?
  };
}
