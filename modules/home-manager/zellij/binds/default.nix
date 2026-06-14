{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.zellij;
  mkKeys =
    keys:
    let
      args = keys._args or [ ];
      children = keys._children or [ ];
    in
    {
      _args = args;
      _children =
        keys
        |> filterAttrs (k: _: k != "_args" && k != "_children")
        |> lib.mapAttrsToList (
          k: v: {
            bind = {
              _args = [ k ];
              _children = v;
            };
          }
        )
        |> (cs: children ++ cs);
    };
in
{
  options.my.home.zellij = {
    prefix-key = mkOption {
      description = "Prefix to enter/exit locked mode";
      type = types.str;
      default = "Ctrl b";
    };
    keybinds = mkOption { };
  };
  config = lib.mkIf cfg.enable {
    _module.args.my.zellij = {
      inherit mkKeys;
      combinemaps =
        { regular, returnToLocked }:
        regular // mapAttrs (_: v: v ++ [ { SwitchToMode._args = [ "locked" ]; } ]) returnToLocked;
      tabKeys =
        prefix:
        lib.range 1 10
        |> map (ix: {
          "${prefix} ${if ix == 10 then "0" else toString ix}" = [ { GoToTab._args = [ ix ]; } ];
        })
        |> foldl' lib.recursiveUpdate { };
      mkHelp =
        {
          mode ? null,
          args ? null,
          ignore ? [ "Ctrl h" ],
        }:
        let
          binds =
            config.programs.zellij.settings.keybinds._children
            |> filter (
              bs: ((attrNames bs |> head) == mode && (args == null || all (arg: elem arg args) bs.${mode}._args))
            )
            |> map (bs: bs.${bs |> attrNames |> head}._children)
            |> flatten
            |> filter (b: b.bind._args |> head |> (key: elem key ignore |> (x: !x)));
          # |> filter (b: (!(any (key: elem key ignore)) (b.bind._args or throw b)));
          # ;
        in
        [
          {
            LaunchOrFocusPlugin = {
              _args = [ "file:${pkgs.zellijPlugins.zellij-forgot}" ];
              _children =
                let
                  keys =
                    binds
                    |> map (
                      { bind }:
                      let
                        obj = head bind._children;
                        key = head bind._args;
                        cmd = attrNames obj |> head;
                        args = obj.${cmd}._args or [ ] |> map toString;
                      in
                      {
                        "\"${concatStringsSep " " ([ cmd ] ++ args)}\"" = key;
                      }
                    );
                in
                [
                  { "\"LOAD_ZELLIJ_BINDINGS\"" = "false"; }
                  { "\"show keybinds\"" = "Ctrl h"; }
                ]
                ++ keys
                ++ [ { floating = true; } ];
            };
          }
          { SwitchToMode._args = [ "locked" ]; }
        ];
    };
    programs.zellij.settings.keybinds = {
      _props = {
        clear-defaults = true;
      };
      _children = map (mapAttrs (_: mkKeys)) cfg.keybinds;
    };
  };
}
