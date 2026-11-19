# Values for my.diskUnlock (./default.nix) shared by every host, including hosts outside this
# repo that import the flake's `mmodules`: the one place to change them.
{ lib, public-keys, ... }:
{
  my.diskUnlock = {
    # The tang Pi (hardware/tang), on ethernet in 10.5.10.0/24. The initrd resolves the name
    # through networkd's DHCP DNS servers and systemd-resolved (docs/disk-unlock.md). The URL is
    # copied into each LUKS header by `clevis luks bind`: changing it here needs a re-bind.
    tang.url = lib.mkDefault "http://tang.localdomain:7654";
    # secrets/keys (the GitHub keys), like the users' authorized_keys (modules/nixos/user.nix)
    ssh.authorizedKeys = lib.mkDefault public-keys;
  };
}
