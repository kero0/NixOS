{
  services = {
    # Printing
    printing.enable = true;

    # GPU
    switcherooControl.enable = true;

    # BT
    blueman.enable = true;

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

    # Dell (TLP 65-dell): start 50..95, stop 55..100
    tlp.settings.START_CHARGE_THRESH_BAT0 = 50;
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

  # u2f key
  security.pam.u2f = {
    enable = true;
    settings.cue = true;
  };
}
