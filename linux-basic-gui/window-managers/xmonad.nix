{ config, lib, pkgs, modulesPath, ... }: {
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableConfiguredRecompile = true;
    enableContribAndExtras = true;
    extraPackages = h: (with h; [ xmonad-contrib xmonad regex-compat ]);
  };

  environment.systemPackages = with pkgs; [
    trayer
    xmobar
    lxsession
    groff
    alsa-utils
    pavucontrol
    xob
    psmisc
  ];
}
