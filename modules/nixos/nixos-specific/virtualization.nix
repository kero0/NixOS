{ pkgs, config, lib, ... }:
let cfg = config.my.virtualization; in
  with lib; {
    options.my.virtualization.enable = mkEnableOption "Enable my virtualization setup";
    config = lib.mkIf cfg.enable {
      boot.binfmt.emulatedSystems = lib.lists.optional (pkgs.system == "x86_64-linux") "aarch64-linux";
      virtualisation = {
	docker = {
          enable = true;
          storageDriver = lib.mkIf (config.fileSystems."/".fsType == "btrfs") "btrfs";
          rootless = {
            enable = true;
            setSocketVariable = true;
          };
	};

	oci-containers = { backend = "docker"; };
	libvirtd = {
          enable = true;
          qemu.swtpm.enable = true;
          onBoot = "ignore";
      };
      spiceUSBRedirection.enable = true;
    };
    programs.dconf.enable = true;
    users.users.${config.my.user.username}.extraGroups = [ "docker" "libvirtd" ];
    environment.systemPackages = with pkgs; [ distrobox virt-manager ];
  };
}
