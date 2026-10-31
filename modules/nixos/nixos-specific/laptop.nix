{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.laptop;
in
{
  options.my.laptop.enable = lib.mkEnableOption "TLP/thermald power management, hybrid-sleep on lid close, PipeWire and network scanners";

  config = lib.mkIf cfg.enable {
    # TLP owns the power tunables; powertop --auto-tune at boot would overwrite them
    # (https://linrunner.de/tlp/faq/powertop.html)
    powerManagement.powertop.enable = false;

    security.rtkit.enable = true;

    services = {
      logind.settings.Login = {
        HandleLidSwitch = "hybrid-sleep";
        HandleLidSwitchExternalPower = "hybrid-sleep";
      };

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      thermald.enable = true;
      power-profiles-daemon.enable = false;
      # the battery charge start threshold is per machine (Dell and Lenovo accept different
      # ranges): set services.tlp.settings.START_CHARGE_THRESH_BAT0 in the host's config
      tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 20;

          # stop charging at 80 % for battery health
          STOP_CHARGE_THRESH_BAT0 = 80;

          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;
        };
      };
    };

    # scanners, including driverless network ones (eSCL/WSD) via sane-airscan
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
    };
    users.users.${config.my.user.username}.extraGroups = [
      "scanner"
      "lp"
    ];
  };
}
