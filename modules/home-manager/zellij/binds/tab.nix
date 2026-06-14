{ my, ... }:
let
  inherit (my.zellij) combinemaps tabKeys mkHelp;
in
{
  my.home.zellij.keybinds = [
    {
      tab =
        let
          returnToLocked = {
            "c" = [ { NewTab = { }; } ];
            "x" = [ { CloseTab = { }; } ];
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
