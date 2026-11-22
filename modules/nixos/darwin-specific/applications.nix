{
  config,
  lib,
  pkgs,
  myuser,
  ...
}:
{
  environment.pathsToLink = [ "/Applications" ];
  system.activationScripts.applications.text =
    let
      dir = "/Applications/Nix Apps";

      env' = pkgs.buildEnv {
        name = "macOS-applications";
        paths = config.environment.systemPackages ++ config.users.users."${myuser}".packages;
        pathsToLink = [ "/Applications" ];
      };
      env = "${env'}/Applications";

      basename = s: lib.lists.last (lib.splitString "/" s);

      # This fails if the path contains a space, but I don't think that's a problem with nix paths.
      files-to-link' = pkgs.runCommandLocal "files-to-link" { } ''
        find '${env}' -maxdepth 1 -type l -exec '${pkgs.coreutils}/bin/readlink' -f '{}' + > $out
      '';
      files-to-link = builtins.filter (s: s != "") (
        lib.splitString "\n" (builtins.readFile files-to-link')
      );

      commands = map (p: ''
        make new alias file at POSIX file "${dir}" to POSIX file "${p}"
        set name of result to "${basename p}"
      '') files-to-link;
    in
    lib.mkForce ''
      echo "Setting up macOS applications in ${dir}"

      if [ -e "${dir}" ]; then
        if [ ! -d "${dir}" ]; then
          echo "ERROR: ${dir} exists but is not a directory" >&2
          exit 1
        fi
        echo "Removing old applications"
        $DRY_RUN_CMD rm -rf "${dir}" || exit 1
      fi

      $DRY_RUN_CMD mkdir -p "${dir}"
      $DRY_RUN_CMD chown "${myuser}" "${dir}"
      $DRY_RUN_CMD chmod 755 "${dir}"

      $DRY_RUN_CMD /usr/bin/osascript <<EOF
        tell application "Finder"
          ${lib.concatStringsSep "\n\n    " commands}
        end tell
      EOF
    '';
}
