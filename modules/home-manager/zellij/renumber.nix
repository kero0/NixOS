{
  config,
  lib,
  pkgs,
  ...
}:
let
  renumber = pkgs.writeShellApplication {
    name = "zellij-renumber";
    runtimeInputs = [
      pkgs.jq
      config.programs.zellij.package
    ];
    text = ''
      case ''${1:-} in
        -h | --help)
          echo "usage: zellij-renumber   renumber this session's default-named tabs (Tab #N) by position"
          exit 0
          ;;
      esac
      [ -n "''${ZELLIJ_SESSION_NAME:-}" ] || { echo "zellij-renumber: not in a zellij session" >&2; exit 1; }
      zellij action list-tabs -j 2>/dev/null |
        jq -r '.[] | select(.name | test("^Tab #[0-9]+$")) | select(.name != "Tab #\(.position + 1)")
               | "\(.tab_id) Tab #\(.position + 1)"' |
        while read -r id name; do zellij action rename-tab-by-id "$id" "$name"; done
    '';
  };
in
{
  options.my.home.zellij.renumberTabs = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    default = {
      Run = {
        _args = [ "${renumber}/bin/zellij-renumber" ];
        in_place = true;
        close_on_exit = true;
      };
    };
    description = "The keybind action that renumbers the tabs, to follow ones that open or close tabs.";
  };
  config = lib.mkIf config.my.home.zellij.enable {
    home.packages = [
      renumber
      (pkgs.man-pages.fromFiles { "zellij-renumber.1" = ./zellij-renumber.1.md; })
    ];
  };
}
