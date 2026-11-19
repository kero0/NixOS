# Disk unlocking: tang, ssh, FIDO2, password

Every encrypted host has its root in LUKS2 volume `crypted` on
`/dev/disk/by-partlabel/disk-main-luks` (disko). `my.diskUnlock`
(`modules/nixos/nixos-specific/disk-unlock/`) sets up the systemd initrd
so the disk opens without typing at home, and remotely or by hand
everywhere else.

| Host | Auto-unlock (clevis) | Network in the initrd | ssh | FIDO2 |
|---|---|---|---|---|
| justice | sss t=2: tpm2 (PCR 7) **and** tang | Wi-Fi (home SSID), USB ethernet | yes | if plugged in |
| Kirols-xps9575 | tang | Wi-Fi (home SSID), USB ethernet | yes | if plugged in |
| hass | tang | ethernet | yes | (if enrolled) |
| theater | tang | ethernet | yes | (if enrolled) |
| tang | not encrypted: it must never depend on itself | | | |

Shared values are set once, in `disk-unlock/site.nix`: the tang URL
`http://tang.localdomain:7654`, and the ssh keys allowed into the initrd
(`secrets/keys`).

## Applying the patches

The series is `/work/patches/disk-unlock/0001…0009-*.patch` (`git am`).

**Apply now: 0001-0006.**
- 0001 the module, 0002 `unlock-remote`, 0003 tang, 0004 the ESP-derived
  `configurationLimit`, 0005 justice, 0006 this guide.
- Effect:
  - justice switches to the new unlock setup; do its checklist below;
  - tang turns Wi-Fi off;
  - hass and theater keep their layout, but their `configurationLimit`
    becomes 2 (derived from their 512M ESP with the default 100 MiB per
    generation) until their own patch;
  - the xps is unchanged.

**Apply at each host's reinstall, not before: 0007 (xps9575), 0008 (hass),
0009 (theater).**
- They're independent; apply any of them, in any order, on top of
  0001-0006.
- Each one moves the host's filesystems to `/dev/mapper/crypted`. A host
  still on its old, unencrypted disk can't boot that configuration.
- hass and theater auto-upgrade from `github:kero0/nixos#<host>`: if the
  patch lands on main before the reinstall, hass switches to it and
  reboots, and theater picks it up at the next boot.
- So:
  1. Apply the host's patch in a local checkout.
  2. Reinstall from that checkout, using `--flake .#<host>` in the disko and
     `nixos-install` commands below.
  3. Push to main only once the host runs its encrypted install.

Markers used below: **[once]** = once per device; **[reinstall]** = again
after every reinstall; **[event]** = when the event happens.

## How the unlock order really works

systemd-cryptsetup (systemd 262, `src/cryptsetup/cryptsetup.c`) cannot try
"tang, then ssh, then FIDO2, then password" one after another. For each
volume it does this:

1. **LUKS2 tokens, through the libcryptsetup plugins.** A FIDO2 key that is
   plugged in at boot is used (touch, and PIN if it was enrolled with one).
   With no key it moves on at once; it doesn't wait. That's why the crypttab
   has no `tpm2-measure-pcr=` (it turns the plugins off) and no
   `fido2-device=` (it waits up to `token-timeout`; that's
   `my.diskUnlock.fido2.wait`, off by default).
   - Any *systemd-tpm2* token left in the header would also be used here,
     and it unlocks anywhere. `disk-unlock-bind` warns about one; wipe it
     (justice, below).
2. **One password prompt**, answered by whichever of these comes first:
   - **clevis** (`clevis-luks-askpass`): decrypts the binding stored in the
     LUKS header. That's tang, or on justice tpm2 *and* tang. It retries every
     0.5 s while the prompt is up, so it picks the network up whenever it
     comes, and it never blocks the prompt.
   - **ssh**: `unlock-remote` pipes the host's remote-unlock passphrase into
     `/bin/unlock-disk` over the initrd sshd (port 2222). That answers only
     the disk prompt, never a FIDO2 PIN prompt.
   - **the keyboard**: the usual console prompt.

   A wrong answer re-asks. There is no timeout.

So the effective order is FIDO2 (if present), then {tang | ssh | keyboard}
in parallel:
- At home, tang answers within seconds of the network coming up.
- Away, the prompt is on screen at once.

**The network.** networkd runs DHCP on every wired link, and on the Wi-Fi
link via `wpa_supplicant@<if>` on the laptops. `wait-online` gives up after
20 s; that only delays clevis's first try. The tang name resolves in the
initrd:
- systemd-resolved runs there and takes the DHCP DNS servers (router
  10.5.10.1).
- With no nsswitch.conf, glibc uses "files dns".
- `/etc/resolv.conf` points to resolved's stub.

Away from home the name doesn't resolve, or resolves to a server that has
no tang keys. Either way clevis fails and the prompt stays.

**Where the secrets are.**
- The clevis binding (including the tang URL) is in the LUKS header.
- The initrd ssh host key and the Wi-Fi PSK are in the initrd on the
  **unencrypted ESP**. Anyone holding the disk can read them. That's why:
  - the ssh host key is a dedicated one;
  - the remote-unlock passphrase has its own revocable keyslot;
  - justice binds tpm2 *and* tang, so a stolen PSK alone doesn't open it.

## The tang server (`hardware/tang`)

The Pi runs tangd on port 7654 over ethernet. The router (10.5.10.1) serves
the name `tang.localdomain`. Only 192.168.1.0/24 and 10.5.0.0/16 may connect.

- **Install** [reinstall]: `nix run .#mk-tang-sd -- /dev/sdX` writes the SD
  image. Then **restore the keys** (below) before any client boots.
- **Check** from a client:
  `curl -sf http://tang.localdomain:7654/adv | head -c 80; echo`
  should print JSON.
- **Thumbprints.** `clevis luks bind` shows the signing key's thumbprint
  and asks whether to trust it. Compare it with what the Pi has:

  ```sh
  ssh -p 9639 tang.localdomain                                    # then, on the Pi:
  J=$(nix build --no-link --print-out-paths nixpkgs#jose)/bin/jose
  for k in $(sudo ls /var/lib/private/tang); do echo "$k $(sudo $J jwk thp -i /var/lib/private/tang/$k)"; done
  ```

  `tang-show-keys` doesn't work on the Pi itself: tangd only accepts the LAN
  ranges, not localhost.

### Key backup [once, and after every rotation]

tangd creates its keys in `/var/lib/private/tang` on the first request, and
they exist only on the SD card. Lose them and every binding stops working.
Anyone who has them can unlock every client from anywhere. So keep the backup
**outside the repo**, offline, encrypted:

```sh
ssh -p 9639 tang.localdomain 'sudo tar -C /var/lib/private -cf - tang' \
  | age -R secrets/keys -o ~/tang-keys-$(date +%F).tar.age
```

### Key restore [reinstall / new SD card]

```sh
ssh -p 9639 tang.localdomain 'sudo systemctl stop tangd.socket && sudo rm -rf /var/lib/private/tang'
age -d -i ~/.ssh/id_ed25519 ~/tang-keys-YYYY-MM-DD.tar.age \
  | ssh -p 9639 tang.localdomain 'sudo tar -C /var/lib/private -xf - && sudo systemctl start tangd.socket'
```

systemd re-owns the state directory for tangd's dynamic user on the next
start. Compare the thumbprints with the old ones.

### Key rotation [event: yearly, or after a leak]

This follows tang's README, "Key Rotation":
1. Generate new keys on the Pi (`J` as in "Thumbprints"):

   ```sh
   sudo $J jwk gen -i '{"alg":"ES512"}' -o /var/lib/private/tang/sig-$(date +%F).jwk
   sudo $J jwk gen -i '{"alg":"ECMR"}' -o /var/lib/private/tang/exc-$(date +%F).jwk
   ```
2. Hide the old keys: rename each `X.jwk` to `.X.jwk`. Hidden keys still
   decrypt but aren't advertised.
3. Re-bind every client: `sudo clevis luks regen -d /dev/disk/by-partlabel/disk-main-luks -s <slot>`.
4. Take a new backup. Delete the hidden keys only once every client has
   re-bound.

## Per-device checklist

`DEV=/dev/disk/by-partlabel/disk-main-luks` and `H=<hostname>` throughout.
Run the commands in a checkout of this repo, on the host, unless noted.
`sudo systemd-cryptenroll $DEV` lists the keyslots and tokens at any time.
`sudo clevis luks list -d $DEV` lists the clevis bindings.

### Steps common to every host

1. **Initrd ssh host key** [reinstall]. Do this before the first `nh os boot`
   with `my.diskUnlock.ssh`; a missing file fails the bootloader install:

   ```sh
   sudo install -d -m 700 /etc/secrets/initrd
   sudo ssh-keygen -t ed25519 -N "" -C $H-initrd -f /etc/secrets/initrd/ssh_host_ed25519_key
   echo "$H-initrd $(sudo cut -d' ' -f1,2 /etc/secrets/initrd/ssh_host_ed25519_key.pub)" >> secrets/unlock/known_hosts
   ```

   Commit `secrets/unlock/known_hosts`, replacing the host's old line if
   there was one.
2. **Wi-Fi config** (laptops) [reinstall; or event: home Wi-Fi changes].
   Only the home network goes in this file:

   ```sh
   ip link                                              # interface = my.diskUnlock.wifi.interface?
   readlink /sys/class/net/wlp0s20f3/device/driver      # driver = my.diskUnlock.wifi.kernelModules?
   wpa_passphrase 'HOME-SSID' | sed '/#psk=/d' | sudo install -m 600 /dev/stdin /etc/secrets/initrd/wpa_supplicant.conf
   ```

   `wpa_passphrase` reads the passphrase from stdin. The hashed `psk=` is
   still enough to join the network. After changing the file, run
   `nh os boot` again: the copy in the initrd is only updated when the
   bootloader is installed.
3. **Wired NIC driver** [once]:
   `readlink /sys/class/net/<if>/device/driver` should be in
   `my.diskUnlock.network.kernelModules`. The host files list inferred
   drivers; fix them if they're wrong.
4. **`nh os boot` + reboot** [after any config change that touches the
   initrd]: `nh os boot . && sudo reboot`. The keyslots below can be added
   before or after.
5. **LUKS header backup** [reinstall, and after every keyslot change]:

   ```sh
   sudo cryptsetup luksHeaderBackup $DEV --header-backup-file /root/$H-luks-header.img
   sudo cat /root/$H-luks-header.img | age -R secrets/keys -o ~/$H-luks-header-$(date +%F).img.age
   sudo rm /root/$H-luks-header.img
   ```

   Keep it offline, not in the repo. A header backup still opens with the
   keyslots it had when it was taken.
6. **Keyslots**, each [reinstall] (`systemd-cryptenroll` / `clevis` ask for
   an existing passphrase):
   - **Password**: the one typed at `disko` format time. Keep it; it's the
     last resort.
   - **clevis** (tang, or sss tpm2+tang on justice): `sudo disk-unlock-bind`.
     It prints and runs the `clevis luks bind -d $DEV …` for this host's
     policy. Check the thumbprint it shows against the tang server's.
     Without the helper:
     - tang: `sudo clevis luks bind -d $DEV tang '{"url":"http://tang.localdomain:7654"}'`
     - sss: `sudo clevis luks bind -d $DEV sss '{"t":2,"pins":{"tang":[{"url":"http://tang.localdomain:7654"}],"tpm2":{"pcr_bank":"sha256","pcr_ids":"7"}}}'`
     - The URL is copied into the header. If it changes, re-bind with
       `sudo clevis luks regen -d $DEV -s <slot>`, or with
       `clevis luks unbind -d $DEV -s <slot>` and then `disk-unlock-bind`.
   - **Remote-unlock passphrase (ssh)**: random, enrolled with
     systemd-cryptenroll, stored with age in the repo:

     ```sh
     pw=$(head -c 32 /dev/urandom | base64 -w0)
     sudo env NEWPASSWORD="$pw" systemd-cryptenroll --password $DEV
     printf %s "$pw" | age -R secrets/keys -o secrets/unlock/$H.age; unset pw
     ```

     Commit `secrets/unlock/$H.age`. To revoke it, run
     `sudo systemd-cryptenroll --wipe-slot=<slot> $DEV` and enroll a new one.
   - **FIDO2** [once per key]:
     `sudo systemd-cryptenroll --fido2-device=auto $DEV`. Defaults are PIN
     and touch; `--fido2-with-client-pin=no` makes it touch only. Enroll a
     second key the same way.

### justice (existing install, no reinstall)

1. Do steps 1 (ssh key), 2 (Wi-Fi, `wlp0s20f3`) and 3 above, then the
   header backup.
2. `nh os boot . && sudo reboot`. The old systemd-tpm2 token still unlocks
   at this point.
3. `sudo disk-unlock-bind` (sss tpm2+tang), the ssh passphrase, and FIDO2.
4. **Wipe the old TPM2 token**: `sudo systemd-cryptenroll --wipe-slot=tpm2 $DEV`.
   Without this, plugin mode keeps unlocking anywhere.
5. Take a new header backup, then run the tests below.
6. [event] After any firmware, BIOS, dbx or Secure Boot key change (fwupd,
   `sbctl`), PCR 7 changes. The next boot falls back to the prompt; then run
   `sudo clevis luks regen -d $DEV -s <sss slot>`. See "Recovery".

### Kirols-xps9575, hass, theater (reinstall with disko)

This wipes the disk. Back up first: /home, anything else needed, and the
xps's `/etc/ssh/ssh_host_*` (its agenix identity).

1. Boot the installer: `nix build .#images.x86_64-linux-iso`, or
   `.#images.$H`, which carries the host's system.
2. Get a checkout with the host's patch applied ("Applying the patches"),
   e.g. `git clone https://github.com/kero0/nixos && cd nixos && git am 000N-*.patch`.
   Partition, encrypt and mount. Check `lsblk` first: disko.nix assumes
   `/dev/nvme0n1`. disko asks for the LUKS password.

   ```sh
   sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- \
     --mode destroy,format,mount --flake .#$H
   ```

3. Create the initrd secrets **under /mnt** (`nixos-install` installs the
   bootloader inside /mnt):
   - step 1 with `/mnt/etc/secrets/initrd/...`;
   - on the xps, step 2 into `/mnt/etc/secrets/initrd/wpa_supplicant.conf`;
   - on the xps, restore `/mnt/etc/ssh/ssh_host_*`.
4. Install: `sudo nixos-install --flake .#$H --no-root-passwd`, then
   reboot. Type the password at the prompt. Push the patch to main now.
5. On the running host: the header backup, and the keyslots (clevis, ssh,
   FIDO2 on the xps). Commit `known_hosts` and `$H.age`, then run the tests.

### Hosts outside this repo

They import this flake's `mmodules`, so they get `my.diskUnlock` and
`site.nix`'s defaults (the tang URL, `secrets/keys`). Nothing refers to this
repo's `hardware/`.

```nix
{
  inputs.kero0.url = "github:kero0/nixos";
  outputs = { kero0, ... }: {
    nixosConfigurations.myhost = kero0.inputs.nixpkgs.lib.nixosSystem {
      modules =
        kero0.mmodules { hostname = "myhost"; myuser = "kirolsb"; system = "x86_64-linux"; age = false; }
        ++ [
          ./hardware-configuration.nix
          ./disko.nix # LUKS name "crypted", as in hardware/hass/nixos/disko.nix
          {
            my.diskUnlock = {
              enable = true;
              tang.enable = true; # tang.tpm2.enable = true; for sss tpm2+tang
              ssh.enable = true;
              network.kernelModules = [ "e1000e" ]; # readlink /sys/class/net/<if>/device/driver
              # wifi = { enable = true; interface = "wlp1s0"; kernelModules = [ "iwlwifi" "iwlmvm" ]; };
              # devices = [ "crypted" ];  # other boot.initrd.luks.devices names
            };
          }
        ];
    };
    # unlock-remote with this flake's own secrets dir (<host>.age + known_hosts):
    packages.x86_64-linux.unlock-remote =
      kero0.packages.x86_64-linux.unlock-remote.override { unlockDir = ./secrets/unlock; };
  };
}
```

Without the override:
`nix run github:kero0/nixos#unlock-remote -- -d ./secrets/unlock myhost`,
or `UNLOCK_DIR=... nix run ...`. Then follow the per-device checklist.

## Testing each fallback

| What | How | Expected |
|---|---|---|
| clevis binding, without rebooting | `sudo clevis luks pass -d $DEV -s <slot> > /dev/null && echo ok` (needs tang, and the TPM for sss) | `ok` |
| tang at boot | boot at home without touching anything; afterwards `journalctl -b -u clevis-luks-askpass` | unlocks within seconds of the network |
| Wi-Fi (laptops) | the same, with no cable; `journalctl -b -u wpa_supplicant@<if>` | associated, unlocked |
| password | `ssh -p 9639 tang.localdomain sudo systemctl stop tangd.socket`, then reboot the client | the prompt stays; typing works |
| ssh | tang stopped as above; from another machine `nix run .#unlock-remote -- $H` (or `-- $H <IP>`) | `unlock-disk: sent passphrase for /dev/disk/by-partlabel/disk-main-luks`, boot goes on |
| wrong ssh passphrase | `echo wrong \| ssh -p 2222 -o HostKeyAlias=$H-initrd -o UserKnownHostsFile=secrets/unlock/known_hosts root@$H.localdomain unlock-disk` | the prompt comes back |
| FIDO2 | plug the key in before power-on, tang stopped | touch (and PIN), unlocked |

Afterwards: `ssh -p 9639 tang.localdomain sudo systemctl start tangd.socket`.
`unlock-remote -h` lists its options: `-d`/`$UNLOCK_DIR`,
`-i`/`$AGE_IDENTITY`, `-k`/`$UNLOCK_SSH_KEY`, `-p`/`$UNLOCK_PORT`, `-t`, and
`$UNLOCK_DOMAIN`.

## Recovery

- **The prompt is always there.** Whatever breaks (tang, TPM, network),
  typing the password, or `unlock-remote`, still opens the disk.
- **A firmware update broke PCR 7 (justice).** fwupd capsules, BIOS
  settings, dbx updates and `sbctl` key changes all change PCR 7. Unlock by
  password, ssh or FIDO2, then reseal to the new state:
  `sudo clevis luks regen -d $DEV -s <sss slot>`. Before a planned
  firmware update, have the password (or a FIDO2 key) at hand.
- **tang lost** (SD card dead, Pi replaced):
  - With the key backup: re-flash, restore the keys, and every binding works
    again.
  - Without it: the new tang has new keys, so every host falls back to the
    prompt. On each host, unlock by hand, then run
    `sudo clevis luks unbind -d $DEV -s <slot>` and `sudo disk-unlock-bind`.
- **The tang URL changed:** re-bind as above. The URL is in each header,
  so editing `site.nix` alone does nothing for existing bindings.
- **`nh os boot` fails with "failed to create initrd secrets":**
  `/etc/secrets/initrd/ssh_host_ed25519_key` or `wpa_supplicant.conf` is
  missing. Create it (steps 1 and 2).
- **Looking inside the initrd:**
  - When ssh works: `ssh -p 2222 -o HostKeyAlias=$H-initrd -o UserKnownHostsFile=secrets/unlock/known_hosts root@$H.localdomain`
    gives a root shell. From there, `systemctl status`, `journalctl -b`
    and `ls /run/systemd/ask-password`.
  - Otherwise use `rd.systemd.debug_shell`, a root shell on tty9:
    - systemd-boot hosts (xps, hass, theater): press `e` in the boot menu
      and append it.
    - lanzaboote (justice): the command line is signed into the UKI and
      can't be edited under Secure Boot. Add
      `boot.kernelParams = [ "rd.systemd.debug_shell" ];` temporarily and
      run `nh os boot`.
- **The header is damaged, or a wipe went wrong:** from a live USB,
  `age -d … > hdr.img`, then
  `sudo cryptsetup luksHeaderRestore $DEV --header-backup-file hdr.img`.
- **The ESP is full** (`nh os boot` / `switch` fails while installing the
  bootloader). Every nixpkgs bump brings a new kernel and initrd, and each
  distinct one is a file on the ESP:
  - lanzaboote stores the kernel and initrd once per content hash in
    `EFI/nixos/`, plus a 0.2 MB signed stub per generation in `EFI/Linux/`;
  - systemd-boot stores them once per store path (initrd + secrets) in
    `EFI/nixos/`, plus an entry file per generation.

  So `boot.loader.systemd-boot.configurationLimit` (lanzaboote uses the same
  value) is derived in `modules/nixos/nixos-specific/boot.nix`:
  `floor(0.7 × my.boot.esp.sizeMiB / my.boot.esp.generationMiB) − 1`, with a
  minimum of 2. The −1 is for the generation being written before the old
  ones are removed.
  - `sizeMiB` comes from the host's disko EF00 partition.
  - `generationMiB` is measured per host and set in its `my.nix`: justice 85,
    xps 110, hass 70, theater 100; the default for other hosts is 100.

  | Host | ESP | Per generation | Limit |
  |---|---|---|---|
  | justice | 512 MB | 85 MB | 3 |
  | Kirols-xps9575 | 1 GB | 110 MB | 5 |
  | hass | 511 MB | 70 MB | 4 |
  | theater | 511 MB | 100 MB | 2 |

  - Check the space with `df -h /boot` and `sudo du -sh /boot/EFI/*`.
    Measure a host's generation with
    `du -mL /run/current-system/kernel /run/current-system/initrd`.
  - If the ESP is full:
    1. Free old generations:
       `sudo nix-collect-garbage -d` (or `nh clean all`), then `nh os boot .`.
       Installing the bootloader removes the files of generations it no
       longer lists.
    2. If it's still tight, lower the limit (raise `generationMiB`), or set
       `boot.loader.systemd-boot.configurationLimit` on the host.
    3. Never delete files under `/boot/EFI` by hand while the running
       generation uses them.
  - A host outside this repo gets the same derivation from its disko ESP.
    Without disko, set `my.boot.esp.sizeMiB`; otherwise the limit stays 15.
