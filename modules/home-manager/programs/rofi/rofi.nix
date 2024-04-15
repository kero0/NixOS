{ pkgs, lib, osconfig, config, ... }:
with lib;
let
  cfg = config.my.home.rofi;
  in
  {
    options.my.home.rofi.enable = mkEnableOption "Enable rofi";
    config = mkIf cfg.enable
      (
	let
          # FIXME: currently broken to ABI version mismatch
          # Found other reports online
          plugins = [
            "rofi-calc"
            "rofi-emoji"
            "rofi-power-menu"
          ];
	  in
	  {
            nixpkgs.overlays = builtins.map
              (p: (final: prev: { ${p} = prev.${p}.override { rofi-unwrapped = prev.rofi-wayland-unwrapped; }; }))
              plugins;
            programs.rofi = pkgs.lib.mkIf pkgs.stdenv.isLinux {
              enable = true;
              package = pkgs.rofi-wayland;
              plugins = builtins.map (p: pkgs.${p}) plugins;
              font = "JetBrainsMono Nerd Font 14";
              terminal = "${pkgs.kitty}/bin/kitty";
              cycle = true;
              location = "center";
              theme = ./onedark.rasi;
              extraConfig = {
		modi = "drun,run,window,ssh,";
		kb-primary-paste = "Control+V,Shift+Insert";
		kb-secondary-paste = "Control+v,Insert";
		matching = "regex";
		dpi = 1;
              };
            };
	  }
      );
  }

