{
  lib,
  config,
  my,
  ...
}:
let
  inherit (my.zellij) combinemaps mkHelp;
  copy = [ { Copy = { }; } ];
  copyKeys = {
    "Alt w" = copy;
    "Ctrl Shift c" = copy;
  };
  scroll = {
    SwitchToMode._args = [ "scroll" ];
  };
  scrollKeys = {
    "j" = [ { ScrollDown = { }; } ];
    "Down" = [ { ScrollDown = { }; } ];
    "k" = [ { ScrollUp = { }; } ];
    "Up" = [ { ScrollUp = { }; } ];
    "d" = [ { HalfPageScrollDown = { }; } ];
    "Ctrl d" = [ { HalfPageScrollDown = { }; } ];
    "u" = [ { HalfPageScrollUp = { }; } ];
    "Ctrl u" = [ { HalfPageScrollUp = { }; } ];
    "f" = [ { PageScrollDown = { }; } ];
    "Ctrl f" = [ { PageScrollDown = { }; } ];
    "Space" = [ { PageScrollDown = { }; } ];
    "PageDown" = [ { PageScrollDown = { }; } ];
    "Shift PageDown" = [ { PageScrollDown = { }; } ];
    "b" = [ { PageScrollUp = { }; } ];
    "PageUp" = [ { PageScrollUp = { }; } ];
    "Shift PageUp" = [ { PageScrollUp = { }; } ];
    "g" = [ { ScrollToTop = { }; } ];
    "Home" = [ { ScrollToTop = { }; } ];
    "G" = [ { ScrollToBottom = { }; } ];
    "End" = [ { ScrollToBottom = { }; } ];
  };
in
{
  config = lib.mkIf config.my.home.zellij.enable {
    programs.zellij.settings.nested_session_handling = "fullscreen";
    programs.zellij.settings.copy_on_select = false;

    my.home.zellij.keybinds = [
      {
        scroll =
          let
            returnToLocked = {
              "e" = [
                { EditScrollback = { }; }
              ];
              "q" = [
                { ScrollToBottom = { }; }
                { ScrollToBottom = { }; }
              ];
              "Esc" = [ { ScrollToBottom = { }; } ];
              "Enter" = [ { ScrollToBottom = { }; } ];
              "Ctrl c" = [ { ScrollToBottom = { }; } ];
            };
            regular = scrollKeys // {
              "/" = [
                { SwitchToMode._args = [ "entersearch" ]; }
                { SearchInput._args = [ 0 ]; }
              ];
              "Ctrl h" = mkHelp { mode = "scroll"; };
            };
          in
          combinemaps { inherit regular returnToLocked; };
      }
      {
        entersearch = {
          "Enter" = [ { SwitchToMode._args = [ "search" ]; } ];
          "Esc" = [ scroll ];
          "Ctrl c" = [ scroll ];
        };
      }
      {
        search =
          lib.removeAttrs scrollKeys [
            "j"
            "Down"
            "k"
            "Up"
            "d"
            "u"
            "Ctrl f"
            "PageDown"
            "PageUp"
          ]
          // copyKeys
          // {
            "q" = [
              { ScrollToBottom = { }; }
              { SwitchToMode._args = [ "locked" ]; }
            ];
          };
      }
    ];
  };
}
