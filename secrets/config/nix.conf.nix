{ lib, ... }: {
  age.secrets.nix-conf = lib.mkDefault {
    group = "wheel";
    mode = "0440";
  };
}
