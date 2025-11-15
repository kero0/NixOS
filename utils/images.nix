{
  nixpkgs,
  self,
  mmodules,
}:
nixpkgs.lib.attrsets.concatMapAttrs (host: config: {
  ${host} =
    (self.images.x86_64-linux-iso.extendModules {
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
  x86_64-linux-iso =
    let
      myuser = "kirolsb";
      system = "x86_64-linux";
      hostname = "nixos-installer";
    in
    nixpkgs.lib.nixosSystem {
      modules = mmodules {
        inherit hostname myuser system;
        age = false;
      };
    };
  tang =
    (self.nixosConfigurations.tang.extendModules {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      ];
    }).config.system.build.sdImage;
}
