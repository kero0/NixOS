{
  config,
  lib,
  pkgs,
  myuser,
  ...
}:
{
  imports = [
    ./applications.nix
    ./homebrew.nix
    ./sudo.nix
  ];
  services.nix-daemon.enable = true;
  # shells
  system.activationScripts.postActivation.text = pkgs.lib.mkIf pkgs.stdenv.isDarwin ''
    echo "setting up users' shells..." >&2
    ${lib.concatMapStringsSep "\n" (user: ''
      dscl . create /Users/${user.name} UserShell "${user.shell}"
    '') (lib.attrValues config.users.users)}
  '';
  environment.systemPackages = with pkgs; [ unnaturalscrollwheels ];
}
