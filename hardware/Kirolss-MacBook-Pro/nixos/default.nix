{
  config,
  lib,
  pkgs,
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

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    watchIdAuth = true;
    reattach = true;
  };
  environment.systemPackages = with pkgs; [ unnaturalscrollwheels ];
}
