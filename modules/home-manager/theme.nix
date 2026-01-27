{
  lib,
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

    flavor = mkOption {
      type = types.str;
      default = "latte";
    };
  };
  config = mkIf cfg.enable {
    catppuccin = {
      inherit (cfg) enable flavor accent;
    };
  };
}
