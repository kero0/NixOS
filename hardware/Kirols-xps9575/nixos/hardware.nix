{
  # Printing
  services.printing.enable = true;

  imports = [ ./pipewire.nix ];

  services = {
    # GPU
    switcherooControl.enable = true;

    # BT
    blueman.enable = true;

    # Lid switch
    logind.settings.Login = {
      HandleLidSwitch = "hybrid-sleep";
      HandleLidSwitchExternalPower = "hybrid-sleep";
    };

    # Mouse
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
    xserver = {
      wacom.enable = true;
      displayManager.setupCommands = ''
        xrandr --dpi 192
      '';
      videoDrivers = [
        "amdgpu"
      ];
    };

    # Thermals
    thermald.enable = true;
    power-profiles-daemon.enable = false;
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

        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
      };
    };
  };

  hardware = {
    # Brightness controls
    acpilight.enable = true;
    # BT
    bluetooth.enable = true;
    # CPU
    cpu.intel.updateMicrocode = true;
    # Sensors
    sensor.iio.enable = true;
  };

  # Networking
  time.timeZone = "America/Detroit";
  networking = {
    useDHCP = false;
    interfaces.wlp2s0.useDHCP = true;
    networkmanager.enable = true;
  };

  # Thermals
  powerManagement.powertop.enable = true;

  # u2f key
  security.pam.u2f = {
    enable = true;
    settings.cue = true;
  };
}
