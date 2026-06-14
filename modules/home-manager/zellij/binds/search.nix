{ my, ... }:
let
  inherit (my.zellij) mkHelp;
in
{
  my.home.zellij.keybinds = [
    {
      search = {
        "j" = [ { ScrollDown = { }; } ];
        "Down" = [ { ScrollDown = { }; } ];
        "k" = [ { ScrollUp = { }; } ];
        "Up" = [ { ScrollUp = { }; } ];

        "Ctrl f" = [ { PageScrollDown = { }; } ];
        "PageDown" = [ { PageScrollDown = { }; } ];
        # "Ctrl b" = [ { PageScrollUp = { }; } ];
        "PageUp" = [ { PageScrollUp = { }; } ];

        "d" = [ { HalfPageScrollDown = { }; } ];
        "u" = [ { HalfPageScrollUp = { }; } ];

        "c" = [ { SearchToggleOption._args = [ "CaseSensitivity" ]; } ];
        "w" = [ { SearchToggleOption._args = [ "Wrap" ]; } ];
        "o" = [ { SearchToggleOption._args = [ "WholeWord" ]; } ];
        "s" = [
          { SwitchToMode._args = [ "EnterSearch" ]; }
          { SearchInput._args = [ 0 ]; }
        ];

        "n" = [ { Search._args = [ "down" ]; } ];
        "N" = [ { Search._args = [ "up" ]; } ];

        "Esc" = [ { SwitchToMode._args = [ "Locked" ]; } ];
        "Ctrl h" = mkHelp { mode = "search"; };
      };
    }
  ];
}
