# `nix run .#unlock-remote -- HOST [ADDRESS]`. Hosts outside this repo can keep their secrets
# elsewhere: pass -d DIR / UNLOCK_DIR, or override the default directory:
#   inputs.kero0.packages.${system}.unlock-remote.override { unlockDir = ./secrets/unlock; }
{
  age,
  openssh,
  writeShellApplication,
  unlockDir,
}:
writeShellApplication {
  name = "unlock-remote";
  runtimeInputs = [
    age
    openssh
  ];
  runtimeEnv.defaultUnlockDir = "${unlockDir}";
  text = builtins.readFile ./unlock-remote;
}
