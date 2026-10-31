{
  services = {
    tlp.settings.START_CHARGE_THRESH_BAT0 = 40;
    upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
    };
  };
}
