{ pkgs, config, ... }:
{
  services = {
    # BT
    blueman.enable = true;

    # Mouse
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        horizontalScrolling = true;
        naturalScrolling = true;
        accelSpeed = "0.45";
        accelProfile = "adaptive";
      };
    };

    # touchscreen
    xserver = {
      wacom.enable = true;
    };

    # Printing
    printing.enable = true;
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
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  # Networking
  time.timeZone = "America/Detroit";
  networking = {
    networkmanager.enable = true;
  };

  users.users.${config.my.user.username}.extraGroups = [ "networkmanager" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      intel-media-driver
      vpl-gpu-rt
    ];
  };
}
