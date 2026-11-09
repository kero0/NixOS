{ config, my, ... }:
let
  inherit (my.zellij) combinemaps tabKeys mkHelp;
  renumber = config.my.home.zellij.renumberTabs;
in
{
  my.home.zellij.keybinds = [
    {
      normal =
        let
          returnToLocked = {
            "\\\\" = [ { NewPane._args = [ "Right" ]; } ];
            "-" = [ { NewPane._args = [ "Down" ]; } ];
            "s" = [ { NewPane._args = [ "stacked" ]; } ];
            "x" = [
              { CloseFocus = { }; }
              renumber
            ];
            "c" = [
              { NewTab = { }; }
              renumber
            ];
            "p" = [
              { GoToPreviousTab = { }; }
              renumber
            ];
            "n" = [
              { GoToNextTab = { }; }
              renumber
            ];
            "]" = [ { BreakPaneRight = { }; } ];
            "[" = [ { BreakPaneLeft = { }; } ];
            "b" = [ { BreakPane = { }; } ];
            "i" = [ { FocusGuestSession = { }; } ];
            "o" = [ { FocusHostSession = { }; } ];
            "Alt c" = [ { Copy = { }; } ];
            "Alt v" = [ { EditScrollback = { }; } ];
            "~" = [
              {
                LaunchOrFocusPlugin = {
                  _args = [ "zellij:layout-manager" ];
                  floating = true;
                  move_to_focused_tab = true;
                };
              }
            ];
            "`" = [
              {
                LaunchOrFocusPlugin = {
                  _args = [ "session-manager" ];
                  floating = true;
                  move_to_focused_tab = true;
                };
              }
            ];
          }
          // tabKeys "Ctrl";
          regular = {
            "h" = [ { MoveFocus._args = [ "Left" ]; } ];
            "j" = [ { MoveFocus._args = [ "Down" ]; } ];
            "k" = [ { MoveFocus._args = [ "Up" ]; } ];
            "l" = [ { MoveFocus._args = [ "Right" ]; } ];
            "H" = [ { MovePane._args = [ "Left" ]; } ];
            "J" = [ { MovePane._args = [ "Down" ]; } ];
            "K" = [ { MovePane._args = [ "Up" ]; } ];
            "L" = [ { MovePane._args = [ "Right" ]; } ];
            "r" = [
              { SwitchToMode._args = [ "RenamePane" ]; }
              { PaneNameInput._args = [ 0 ]; }
            ];
            "R" = [
              { SwitchToMode._args = [ "RenameTab" ]; }
              { TabNameInput._args = [ 0 ]; }
            ];
            "Ctrl h" = mkHelp { mode = "normal"; };
            "/" = [
              { SwitchToMode._args = [ "entersearch" ]; }
              { SearchInput._args = [ 0 ]; }
            ];
            "u" = [
              {
                SwitchToMode._args = [ "scroll" ];
              }
              { HalfPageScrollUp = { }; }
            ];
            "PageUp" = [
              {
                SwitchToMode._args = [ "scroll" ];
              }
              { PageScrollUp = { }; }
            ];
          };
        in
        combinemaps { inherit regular returnToLocked; };
    }
  ];
}
