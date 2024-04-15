{ pkgs, config, lib, ... }:
let cfg = config.my.gaming; in
  with lib; {
    options.my.gaming.enable = mkEnableOption "Install gaming dependencies";
    config = lib.mkIf cfg.enable {
      programs.steam = {
	enable = true;
	gamescopeSession.enable = true;
	package = pkgs.steam.override {
          #  withPrimus = true;
          #  withJava = true;
          #  extraPkgs = pkgs: with pkgs; [ bumblebee glxinfo ];
	};
      };
    programs.java.enable = true;
    environment.systemPackages = with pkgs; [
      steam-run-native
      config.programs.steam.package.run
      lutris
    ];
    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };
  };
}
