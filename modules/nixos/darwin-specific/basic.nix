{
  config,
  lib,
  pkgs,
  ...
}:
{
  system.activationScripts.postActivation.text = ''
    echo "setting up users' shells..." >&2
    ${lib.concatMapStringsSep "\n" (user: ''
      dscl . create ${lib.escapeShellArg "/Users/${user.name}"} UserShell ${lib.escapeShellArg user.shell}
    '') (lib.filter (user: user.shell != null) (lib.attrValues config.users.users))}
  '';

  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    watchIdAuth = true;
    reattach = true;
  };
  environment.systemPackages = with pkgs; [ unnaturalscrollwheels ];
}
