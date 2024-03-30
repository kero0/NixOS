{ pkgs, myuser, lib, config, ... }: {
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  virtualisation = {
    docker = {
      enable = true;
      storageDriver =
        lib.mkIf (config.fileSystems."/".fsType == "btrfs") "btrfs";
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
  users.users.${myuser}.extraGroups = [ "docker" "libvirtd" ];
  environment.systemPackages = with pkgs; [ distrobox virt-manager ];
}
