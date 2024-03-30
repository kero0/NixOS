{ pkgs, lib, ... }:
let 
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
in
{
  # configuring sway itself (assmung a display manager starts it)
  systemd.user.targets.sway-session = {
    description = "Sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      autotiling
      swaylock
      swayidle
      wl-clipboard
      mako # notification daemon
      alacritty # Alacritty is the default terminal in the config
      dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
      wlogout
      wofi
      waybar
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };
  environment.systemPackages = with pkgs; [
    brightnessctl
    # pactl
    polkit_gnome
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    jq
    kanshi
    wob

    dbus-sway-environment
    wdisplays
    slurp
    wl-clipboard
    configure-gtk
    cliphist
  ];

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    dbus.enable = true;
  };

  environment.pathsToLink = [ "/libexec" ];
  xdg = {
    autostart.enable = true;
    icons.enable = true;
    menus.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        # xdg-desktop-portal-kde
        # xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      wlr.enable = true;
      xdgOpenUsePortal = true;
    };
  };
}
