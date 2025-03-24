{
  config,
  lib,
  pkgs,
  myuser,
  ...
}:
{
  # shells
  system.activationScripts.my-set-user-shell.text = ''
    echo "setting up users' shells..." >&2
    ${lib.concatMapStringsSep "\n" (user: ''
      dscl . create /Users/${user.name} UserShell "${user.shell}"
    '') (lib.attrValues config.users.users)}
  '';
  environment.systemPackages = with pkgs; [ unnaturalscrollwheels ];
}
