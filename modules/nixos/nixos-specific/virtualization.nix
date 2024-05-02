{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.virtualization;
in
with lib;
{
  options.my.virtualization.enable = mkEnableOption "Enable my virtualization setup";
  config = lib.mkIf cfg.enable {
    boot.binfmt.emulatedSystems = lib.lists.optional (pkgs.system == "x86_64-linux") "aarch64-linux";
    virtualisation = {
      podman = {
        enable = true;
        extraPackages = with pkgs; [ catatonit ];
      };

      oci-containers = {
        backend = "podman";
      };
      libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
        onBoot = "ignore";
      };
      spiceUSBRedirection.enable = true;
    };
    programs.dconf.enable = true;
    users.users.${config.my.user.username}.extraGroups = [
      "podman"
      "libvirtd"
    ];
    environment.systemPackages = with pkgs; [
      distrobox
      virt-manager
    ];
  };
}
