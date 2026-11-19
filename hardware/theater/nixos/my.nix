{ myuser, ... }:
{
  system.autoUpgrade.operation = "boot";
  my = {
    # ESP space per distinct generation: kernel 13.2 + initrd 85.2 MiB (amdgpu firmware), measured 2026-10-31;
    # boot.nix derives configurationLimit from it and the disko ESP size
    boot.esp.generationMiB = 100;
    autoUpgrade.enable = true;
    # tang at home over ethernet, else ssh (`nix run .#unlock-remote -- theater`), the console
    # last (docs/disk-unlock.md). Plain tang: whether this box has a TPM is unknown.
    diskUnlock = {
      enable = true;
      tang.enable = true;
      ssh.enable = true;
      # the NIC is unknown (Intel desktop board, see vmd in hardware.nix): the common Intel and
      # Realtek drivers, inferred; check `readlink /sys/class/net/<if>/device/driver`
      network.kernelModules = [
        "e1000e"
        "igc"
        "r8169"
      ];
    };
    desktop.enable = false;
    fonts.enable = true;
    gaming.enable = true;
    samba.enable = false;
    scripts.enable = false;
    server.enable = true;

    services = {
      basic.enable = true;
      ssh.enable = true;
    };

    user = {
      enable = true;
      username = myuser;
      realName = "Kirols Bakheat";
      passwordHash = null;
    };
  };
}
