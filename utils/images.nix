{
  nixpkgs,
  self,
  mmodules,
}:
let
  installer = nixpkgs.lib.nixosSystem {
    modules = mmodules {
      myuser = "kirolsb";
      system = "x86_64-linux";
      hostname = "nixos-installer";
      age = false;
    };
  };
in
nixpkgs.lib.attrsets.concatMapAttrs (host: config: {
  ${host} =
    (installer.extendModules {
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        {
          isoImage = {
            storeContents = [
              config.config.system.build.toplevel
            ];
            makeEfiBootable = true;
            makeUsbBootable = true;
            squashfsCompression = null;
            compressImage = false;
          };
        }
      ];
    }).config.system.build.isoImage;
}) self.nixosConfigurations

// {
  x86_64-linux-iso = installer.config.system.build.isoImage;
  tang =
    (self.nixosConfigurations.tang.extendModules {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        { boot.supportedFilesystems.zfs = nixpkgs.lib.mkForce false; }
      ];
    }).config.system.build.sdImage;
}
