{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.my.home.shell.alias;
in
{
  options.my.home.shell.alias.enable = mkEnableOption "My common shell aliases";
  config = mkIf cfg.enable (
    let
      mkshort-args = list: pkgs.lib.concatMapStrings (x: " -${x}") list;
      mklong-args = list: pkgs.lib.concatMapStrings (x: " --${x}") list;
      mkcommand =
        pkg: short-args: long-args:
        "${pkgs.${pkg}}/bin/${pkg} ${short-args} ${long-args}";
      base_ls =
        let
          short-args = mkshort-args [
            "a" # all files
            "F" # classify
            "h" # human readable
            "l" # long format
          ];
          long-args = mklong-args [
            "group-directories-first" # group directories before files
            "color=automatic" # colorize the output if not piping
          ];
        in
        mkcommand "eza" short-args long-args;
    in
    {
      home.shellAliases = with pkgs; {
        cat = lib.mkIf config.programs.bat.enable "bat";
        rm = pkgs.lib.mkIf pkgs.stdenv.isDarwin "${darwin.trash}/bin/trash -F";
        trash = pkgs.lib.mkIf pkgs.stdenv.isDarwin "${darwin.trash}/bin/trash -F";
        rs =
          let
            short-args = mkshort-args [
              "A" # preserve ACLs
              "a" # archive mode
              "H" # preserve hard links
              "h" # human readable
              "r" # recursive
              "P" # progress
              "S" # sparse files
              "v" # verbose
            ];
            long-args = mklong-args [
              "numeric-ids" # don't map uid/gid values by user/group name
              "stats" # show transfer stats
            ];
          in
          mkcommand "rsync" short-args long-args;

        # ls
        "l." = "${base_ls} -d .?*";
        ls = base_ls;

        # misc
        ssh = "TERM=xterm-256color ssh";
      };

      programs.fish.shellAliases = {
        ssh = pkgs.lib.mkForce "TERM=xterm-256color command ssh";
      };
    }
  );
}
