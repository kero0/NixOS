{ pkgs, lib, ... }:
{
  # Printing
  services.printing.enable = true;

  # Mouse
  services.xserver = {
    wacom.enable = true;
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        horizontalScrolling = true;
        naturalScrolling = true;
        accelSpeed = "0.35";
        accelProfile = "adaptive";
      };
    };
  };

  # Brightness controls
  hardware.acpilight.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Networking
  time.timeZone = "America/Detroit";
  networking = {
    useDHCP = false;
    interfaces.wlo1.useDHCP = true;
    networkmanager.enable = true;
  };

  # Lid switch
  services.logind = {
    lidSwitch = "hybrid-sleep";
    lidSwitchExternalPower = "hybrid-sleep";
  };
  # Sensors
  hardware.sensor.iio.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      mesa.drivers
      libva
      vaapiVdpau
    ];
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
  # u2f key
  security.pam.u2f = {
    enable = true;
    cue = true;
  };
}
