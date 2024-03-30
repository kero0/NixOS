{ pkgs, ... }:
{
  services.picom = pkgs.lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    package = pkgs.picom;
    experimentalBackends = true;

    opacityRules = [
      "80:class_g     = 'Polybar'"
      "80:class_g     = 'Chromium-browser'"
      "90:class_g     = 'Emacs'"
      "90:class_g     = 'Code'"
      "90:class_g     = 'Xmobar'"
    ];
    activeOpacity = 1.0;
    inactiveOpacity = 0.8;
    menuOpacity = 0.8;

    settings = {
      corner-radius = 18;
      round-borders = 1;

      shadow-radius = 7;


      frame-opacity = 0.7;
      popup_menu = { opacity = 0.8; };
      dropdown_menu = { opacity = 0.8; };
      inactive-opacity-override = false;
      focus-exclude = [
        "class_g = 'Cairo-clock'"
        "class_g = 'Bar'"
        "class_g = 'slop'"
      ];


      blur = {
        method = "kawase";
        strength = 7;
        background = false;
        background-frame = false;
        background-fixed = false;
        kern = "3x3box";
      };


      experimental-backends = true;


      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-client-opacity = true;
      detect-transient = true;
      detect-client-leader = true;

      use-damage = false;

      log-level = "warn";

      noDockShadow = true;
      noDNDShadow = true;

      size-transition = true;
      transition-length = 350;
      transition-pow-x = 0.1;
      transition-pow-y = 0.1;
      transition-pow-w = 0.1;
      transition-pow-h = 0.1;
    };

  };
}
