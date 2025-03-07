{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.git = {
    lfs.enable = true;
    extraConfig = {
      github.user = "kbakheat_ford";
      user.signingKey = "C6F92AA1FA6C97720DD344CA0F9995D80D7ADAFE";
      credentials.helper = "store";
      http.cookiefile = "${config.xdg.configHome}/git/cookies";
      http.cookieFile = "${config.xdg.configHome}/git/cookies";
      push.autoSetupRemote = true;
    };
  };

  nixGL.defaultWrapper = "mesa";
  nixGL.offloadWrapper = "nvidiaPrime";
  nixGL.installScripts = [
    "mesa"
    "nvidiaPrime"
  ];

  wayland.windowManager.hyprland.package = config.lib.nixGL.wrap pkgs.hyprland;
  programs.kitty.package = config.lib.nixGL.wrap pkgs.kitty;
  home.packages = with pkgs; [
    atuin
    android-tools
    android-studio
    jetbrains.idea-ultimate
    scrcpy
    nix
  ];

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;

  xdg.systemDirs.data = [
    "/usr/share/ubuntu"
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
    "/var/lib/flatpak/exports/share"
    "/usr/local/share/"
    "/usr/share/"
    "var/lib/snapd/desktop"
  ];
}
