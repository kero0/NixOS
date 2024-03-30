{ pkgs, ... }:
with pkgs;{
  services.screen-locker = pkgs.lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    xautolock = {
      enable = true;
      detectSleep = true;
      extraOptions = [
        "-notify 60"
        "-notifier \"${libnotify}/bin/notify-send -u critical -t 29000 -- 'LOCKING screen in 30 seconds'\""
      ];
    };
    inactiveInterval = 25;
    lockCmd = "sleep 3 && ${i3lock-fancy}/bin/i3lock-fancy -n";
  };

}
