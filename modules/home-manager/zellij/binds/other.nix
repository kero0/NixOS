{
  my,
  config,
  ...
}:
let
  inherit (my.zellij)
    tabKeys
    mkHelp
    ;
  inherit (config.my.home.zellij) prefix-key;
in
{
  my.home.zellij.keybinds = [
    {
      locked = {
        "${prefix-key}" = [ { SwitchToMode._args = [ "normal" ]; } ];
      };
    }
    {
      shared_except = {
        _args = [ "locked" ];
        "${prefix-key}" = [ { SwitchToMode._args = [ "locked" ]; } ];
        "Ctrl q" = [ { Quit = { }; } ];
        "Ctrl d" = [ { Detach = { }; } ];
        "Ctrl t" = [ { SwitchToMode._args = [ "tab" ]; } ];
        "Ctrl r" = [ { SwitchToMode._args = [ "resize" ]; } ];
        "Ctrl s" = [ { SwitchToMode._args = [ "search" ]; } ];

        "Ctrl h" = mkHelp {
          mode = "shared_except";
          args = [ "locked" ];
        };
        "Ctrl e" = [
          { EditScrollback = { }; }
          { SwitchToMode._args = [ "locked" ]; }
        ];
      };
    }
    {
      shared = {
        "Alt h" = [ { MoveFocus._args = [ "Left" ]; } ];
        "Alt j" = [ { MoveFocus._args = [ "Down" ]; } ];
        "Alt k" = [ { MoveFocus._args = [ "Up" ]; } ];
        "Alt l" = [ { MoveFocus._args = [ "Right" ]; } ];
        "Alt p" = [ { GoToPreviousTab = { }; } ];
        "Alt n" = [ { GoToNextTab = { }; } ];

        "Alt f" = [ { ToggleFloatingPanes = { }; } ];
        "Alt =" = [ { Resize._args = [ "Increase" ]; } ];
        "Alt -" = [ { Resize._args = [ "Decrease" ]; } ];
      }
      // tabKeys "Alt";
    }
    {
      renamepane = {
        "Enter" = [ { SwitchToMode._args = [ "Locked" ]; } ];
        "Esc" = [
          { UndoRenamePane = { }; }
          { SwitchToMode._args = [ "Locked" ]; }
        ];
      };
    }
    {
      renametab = {
        "Enter" = [ { SwitchToMode._args = [ "Locked" ]; } ];
        "Esc" = [
          { UndoRenameTab = { }; }
          { SwitchToMode._args = [ "Locked" ]; }
        ];
      };
    }
    {
      resize = {
        "h" = [ { Resize._args = [ "Increase Left" ]; } ];
        "j" = [ { Resize._args = [ "Increase Down" ]; } ];
        "k" = [ { Resize._args = [ "Increase Up" ]; } ];
        "l" = [ { Resize._args = [ "Increase Right" ]; } ];
        "H" = [ { Resize._args = [ "Decrease Left" ]; } ];
        "J" = [ { Resize._args = [ "Decrease Down" ]; } ];
        "K" = [ { Resize._args = [ "Decrease Up" ]; } ];
        "L" = [ { Resize._args = [ "Decrease Right" ]; } ];
        "Ctrl h" = mkHelp { mode = "resize"; };
      };
    }
  ];
}
