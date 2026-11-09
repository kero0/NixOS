{ config, my, ... }:
let
  inherit (my.zellij) combinemaps tabKeys mkHelp;
  renumber = config.my.home.zellij.renumberTabs;
in
{
  my.home.zellij.keybinds = [
    {
      tab =
        let
          returnToLocked = {
            "c" = [
              { NewTab = { }; }
              renumber
            ];
            "x" = [
              { CloseTab = { }; }
              renumber
            ];
            "h" = [ { GoToPreviousTab = { }; } ];
            "j" = [ { GoToNextTab = { }; } ];
            "k" = [ { GoToPreviousTab = { }; } ];
            "l" = [ { GoToNextTab = { }; } ];
            "p" = [ { GoToPreviousTab = { }; } ];
            "n" = [ { GoToNextTab = { }; } ];
          }
          // tabKeys "";
          regular = {
            "Ctrl h" = mkHelp { mode = "tab"; };
          };
        in
        combinemaps { inherit regular returnToLocked; };
    }
  ];
}
