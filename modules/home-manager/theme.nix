{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.my.home.theme;
in
{
  options.my.home.theme = {
    enable = mkEnableOption "Variation of catppuccin";
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
      inherit (cfg) flavor accent;
      autoEnable = cfg.enable;
    };
  };
}
