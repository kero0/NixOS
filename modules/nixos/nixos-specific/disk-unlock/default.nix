# my.diskUnlock: unattended / remote unlocking of LUKS devices in the systemd initrd.
#
# What systemd-cryptsetup (systemd 262, src/cryptsetup/cryptsetup.c verb_attach) does per volume:
#   1. LUKS2 tokens through the libcryptsetup plugins (FIDO2, and TPM2 if one is enrolled): only
#      if the key is plugged in at boot, no waiting. With fido2.wait it instead waits up to
#      fido2.tokenTimeout for an enrolled FIDO2 key.
#   2. ONE password prompt, answered by whichever comes first, all in parallel:
#        clevis   (clevis-luks-askpass: the tang / sss tpm2+tang binding in the LUKS header,
#                  retried every 0.5 s while the prompt is up, so it waits for the network),
#        ssh      (`unlock-disk` run over the initrd sshd; client: `nix run .#unlock-remote`),
#        keyboard (console).
# Enrolment (clevis luks bind, systemd-cryptenroll) is a manual per-device step: see
# docs/disk-unlock.md. `disk-unlock-bind` (installed when tang.enable) runs the clevis part.
#
# Everything is driven by options so hosts outside this repo (importing the flake's
# `mmodules`) get the same setup. Values shared by every host (tang URL, authorized keys) are
# set once, in ./site.nix.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatMapStringsSep
    escapeShellArg
    literalExpression
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.my.diskUnlock;
  systemd = config.boot.initrd.systemd.package;
  replyPassword = "${systemd}/lib/systemd/systemd-reply-password";

  # Reads one passphrase line on stdin and answers the pending systemd-cryptsetup password
  # requests (Id=cryptsetup:...) with it; leaves other requests (e.g. a FIDO2 PIN) alone.
  # Waits up to $1 seconds (default 120) for a request to appear. Protocol:
  # https://github.com/systemd/systemd/blob/v262/docs/PASSWORD_AGENTS.md
  unlockDisk = pkgs.writeShellScript "unlock-disk" ''
    set -u
    # `age -d` output has no trailing newline: read returns 1 at EOF but still sets pw
    IFS= read -r pw || [ -n "$pw" ] || { echo "unlock-disk: no passphrase on stdin" >&2; exit 2; }
    deadline=$((SECONDS + ''${1:-120}))
    while :; do
      answered=0
      for q in /run/systemd/ask-password/ask.*; do
        [ -e "$q" ] || continue
        id= sock=
        while IFS= read -r line; do
          case "$line" in
            Id=*) id=''${line#Id=} ;;
            Socket=*) sock=''${line#Socket=} ;;
          esac
        done < "$q"
        case "$id" in cryptsetup:*) ;; *) continue ;; esac
        if printf '%s\n' "$pw" | ${replyPassword} 1 "$sock"; then
          echo "unlock-disk: sent passphrase for ''${id#cryptsetup:}" >&2
          answered=$((answered + 1))
        fi
      done
      [ "$answered" -gt 0 ] && exit 0
      [ "$SECONDS" -ge "$deadline" ] && { echo "unlock-disk: no disk password request within ''${1:-120}s" >&2; exit 1; }
      sleep 1
    done
  '';

  # clevis pin + config for `clevis luks bind`
  clevisPin = if cfg.tang.tpm2.enable then "sss" else "tang";
  clevisConfig = builtins.toJSON (
    if cfg.tang.tpm2.enable then
      {
        t = 2;
        pins = {
          tang = [ { inherit (cfg.tang) url; } ];
          tpm2 = {
            pcr_bank = cfg.tang.tpm2.pcrBank;
            pcr_ids = cfg.tang.tpm2.pcrIds;
          };
        };
      }
    else
      { inherit (cfg.tang) url; }
  );

  # The LUKS devices as bash array words "name=device"; the names come from cfg.devices (not from
  # boot.initrd.luks.devices itself: fido2.wait defines entries there -> infinite recursion).
  deviceWords = concatMapStringsSep " " (
    d: escapeShellArg "${d}=${config.boot.initrd.luks.devices.${d}.device}"
  ) cfg.devices;

  bindHelper = pkgs.writeShellApplication {
    name = "disk-unlock-bind";
    runtimeInputs = [
      pkgs.clevis
      pkgs.cryptsetup
      pkgs.gnugrep
    ];
    text = ''
      usage() {
        echo "usage: disk-unlock-bind [-n] [NAME...]"
        echo "  Adds a clevis ${clevisPin} keyslot (my.diskUnlock.tang) to the LUKS devices"
        echo "  my.diskUnlock.devices (default: all). -n: only print the commands."
      }
      dry=
      while getopts nh o; do
        case $o in
          n) dry=1 ;;
          h) usage; exit 0 ;;
          *) usage >&2; exit 2 ;;
        esac
      done
      shift $((OPTIND - 1))
      pin=${escapeShellArg clevisPin}
      conf=${escapeShellArg clevisConfig}
      found=0
      devices=(${deviceWords})
      for entry in "''${devices[@]}"; do
        name=''${entry%%=*} dev=''${entry#*=}
        if [[ $# -gt 0 ]] && ! printf '%s\n' "$@" | grep -qxF "$name"; then continue; fi
        found=1
        echo "+ clevis luks bind -d $dev $pin '$conf'"
        if [[ -z $dry ]]; then
          # in plugin mode an enrolled systemd-tpm2 token unlocks anywhere, bypassing tang
          if cryptsetup luksDump "$dev" | grep -q 'systemd-tpm2'; then
            echo "disk-unlock-bind: warning: $dev has a systemd-tpm2 token; it unlocks without tang." >&2
            echo "  Remove it: systemd-cryptenroll --wipe-slot=tpm2 $dev" >&2
          fi
          clevis luks bind -d "$dev" "$pin" "$conf"
        fi
      done
      [[ $found -eq 1 ]] || { echo "disk-unlock-bind: no such device: $*" >&2; exit 1; }
    '';
  };
in
{
  options.my.diskUnlock = {
    enable = mkEnableOption "tang / ssh / FIDO2 / password unlocking of LUKS devices in the initrd";

    devices = mkOption {
      type = types.listOf types.str;
      default = [ "crypted" ];
      description = "boot.initrd.luks.devices entries this applies to (disko's luks `name`).";
    };

    tang = {
      enable = mkEnableOption ''
        clevis-luks-askpass: answer the password prompt from the clevis binding in the LUKS header
        (bind it with `disk-unlock-bind`)
      '';
      url = mkOption {
        type = types.str;
        example = "http://tang.localdomain:7654";
        description = ''
          tang server URL used by `disk-unlock-bind`. The initrd itself reads the URL from the
          binding in the LUKS header, so changing this only affects new bindings (re-bind with
          `clevis luks regen`, or unbind + `disk-unlock-bind`). A host name must resolve in the
          initrd: systemd-resolved is on there with networkd (resolved.nix) and uses the DHCP
          DNS servers; otherwise use an IP with a DHCP reservation.
        '';
      };
      tpm2 = {
        enable = mkEnableOption ''
          binding with `sss` t=2 over tpm2 + tang: auto-unlock only at home AND with this
          machine's TPM in the expected state (pcrIds)
        '';
        pcrIds = mkOption {
          type = types.str;
          default = "7";
          description = ''
            PCRs the tpm2 pin seals to. 7 = secure-boot state (lanzaboote keys, dbx); firmware
            or dbx updates change it, then clevis fails and you re-bind (`clevis luks regen`).
          '';
        };
        pcrBank = mkOption {
          type = types.str;
          default = "sha256";
          description = "PCR bank for the tpm2 pin.";
        };
      };
    };

    network = {
      ethernet = mkOption {
        type = types.bool;
        default = true;
        description = "DHCP on every wired interface in the initrd.";
      };
      kernelModules = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [
          "r8152"
          "e1000e"
        ];
        description = ''
          Wired NIC drivers the initrd needs (`readlink /sys/class/net/<if>/device/driver`,
          `lspci -k`, `lsusb -t`). Only loaded when the hardware is present.
        '';
      };
      waitOnlineTimeout = mkOption {
        type = types.ints.unsigned;
        default = 20;
        description = ''
          systemd-networkd-wait-online timeout in the initrd (nixpkgs default 120). Only delays
          the first clevis attempt (it retries afterwards); the password prompt is shown anyway.
        '';
      };
    };

    wifi = {
      enable = mkEnableOption "Wi-Fi in the initrd (wpa_supplicant; the PSK ends up on the ESP)";
      interface = mkOption {
        type = types.str;
        example = "wlp0s20f3";
        description = "Wireless interface name (the same predictable name as in stage 2).";
      };
      configFile = mkOption {
        type = types.str;
        default = "/etc/secrets/initrd/wpa_supplicant.conf";
        description = ''
          wpa_supplicant.conf with only the home network(s). A string, not a path: it is copied
          from the running system at bootloader-install time (boot.initrd.secrets) and never
          enters the Nix store. It must exist before `nh os boot`, or the bootloader install fails.
        '';
      };
      ssids = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "If set, networkd only runs DHCP on the Wi-Fi link when associated to one of these SSIDs.";
      };
      kernelModules = mkOption {
        type = types.listOf types.str;
        default = [
          "iwlwifi"
          "iwlmvm"
        ];
        description = "Wi-Fi driver modules (default: Intel). Their firmware is copied into the initrd.";
      };
    };

    ssh = {
      enable = mkEnableOption "initrd sshd for remote unlocking (`unlock-disk`)";
      port = mkOption {
        type = types.port;
        default = 2222;
        description = "initrd sshd port (not stage 2's 9639, so known_hosts entries don't clash).";
      };
      hostKeys = mkOption {
        type = types.listOf types.str;
        default = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        description = ''
          Dedicated initrd host keys (strings: copied via boot.initrd.secrets, not the store).
          Never the stage-2 host keys: these sit unencrypted on the ESP.
        '';
      };
      authorizedKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
        defaultText = literalExpression "[ ] (./site.nix sets the flake's public-keys)";
        description = "Keys allowed to log in as root to the initrd.";
      };
    };

    fido2 = {
      wait = mkOption {
        type = types.bool;
        default = false;
        description = ''
          false (plugin mode): an enrolled FIDO2 key is used if it is plugged in at boot, with no
          waiting. true: add fido2-device=auto,token-timeout= so every boot waits up to
          tokenTimeout for the key before the password prompt; enrol the key first.
        '';
      };
      tokenTimeout = mkOption {
        type = types.ints.unsigned;
        default = 10;
        description = "crypttab token-timeout= in seconds (systemd default 30; 0 = forever).";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.devices != [ ] && lib.all (d: config.boot.initrd.luks.devices ? ${d}) cfg.devices;
          message = "my.diskUnlock.devices must name boot.initrd.luks.devices entries";
        }
        {
          assertion = cfg.ssh.enable -> cfg.ssh.authorizedKeys != [ ];
          message = "my.diskUnlock.ssh.authorizedKeys is empty";
        }
      ];
      boot.initrd = {
        systemd.network = {
          enable = true;
          wait-online = {
            timeout = cfg.network.waitOnlineTimeout;
            anyInterface = true;
          };
        };
        # stage 2 (NetworkManager / dhcpcd) starts from a clean interface
        network.flushBeforeStage2 = true;
        availableKernelModules = cfg.network.kernelModules;
      };
    }

    (mkIf cfg.network.ethernet {
      boot.initrd.systemd.network.networks."20-initrd-ether" = {
        matchConfig.Type = "ether";
        networkConfig.DHCP = "ipv4";
        linkConfig.RequiredForOnline = "routable";
      };
    })

    (mkIf cfg.tang.enable {
      boot.initrd.clevisLuksAskpass = {
        enable = true;
        useTang = true;
      };
      environment.systemPackages = [
        pkgs.clevis
        bindHelper
      ];
    })

    (mkIf (cfg.tang.enable && cfg.tang.tpm2.enable) {
      # The tpm2 pin (clevis-decrypt-tpm2) runs tpm2_createprimary/load/unseal/flushcontext
      # (already in the initrd via clevis-luks-askpass.nix) on /dev/tpmrm0. That needs the TPM
      # drivers (tpm-tis, tpm-crb) and tpm2-tss, whose TCTI libraries tpm2-tools dlopen()s by
      # absolute path; boot.initrd.systemd.tpm2 adds both (systemd/tpm2.nix). tpm2-tss is listed
      # here too so it doesn't depend on systemd's own TPM2 support staying on.
      # Upstream test of this binding: nixos/tests/installer.nix clevisLuksAskpass (sss tpm2+tang).
      boot.initrd.systemd = {
        tpm2.enable = true;
        storePaths = [ pkgs.tpm2-tss ];
      };
      environment.systemPackages = [ pkgs.tpm2-tools ];
    })

    (mkIf cfg.ssh.enable {
      boot.initrd.network.ssh = {
        enable = true;
        inherit (cfg.ssh) port hostKeys authorizedKeys;
      };
      boot.initrd.systemd = {
        extraBin.unlock-disk = "${unlockDisk}";
        storePaths = [ replyPassword ];
      };
    })

    (mkIf cfg.fido2.wait {
      boot.initrd.luks.devices = lib.genAttrs cfg.devices (_: {
        crypttabExtraOpts = [
          "fido2-device=auto"
          "token-timeout=${toString cfg.fido2.tokenTimeout}s"
        ];
      });
    })

    (mkIf cfg.wifi.enable {
      boot.initrd = {
        availableKernelModules = cfg.wifi.kernelModules ++ [
          "ccm"
          "ctr"
          "cmac" # WPA3 / PMF
        ];
        secrets."/etc/wpa_supplicant/wpa_supplicant-${cfg.wifi.interface}.conf" = cfg.wifi.configFile;
        systemd = {
          packages = [ pkgs.wpa_supplicant ]; # wpa_supplicant@.service
          initrdBin = [ pkgs.wpa_supplicant ];
          targets.initrd.wants = [ "wpa_supplicant@${cfg.wifi.interface}.service" ];
          services."wpa_supplicant@" = {
            # otherwise it waits for sysinit.target, i.e. for the disk it is meant to unlock
            unitConfig.DefaultDependencies = false;
            after = [ "initrd-nixos-copy-secrets.service" ];
            before = [
              "initrd-switch-root.target"
              "shutdown.target"
            ];
            conflicts = [
              "initrd-switch-root.target"
              "shutdown.target"
            ];
          };
          network.networks."10-initrd-wlan" = {
            matchConfig = {
              Name = cfg.wifi.interface;
            }
            // lib.optionalAttrs (cfg.wifi.ssids != [ ]) { SSID = cfg.wifi.ssids; };
            networkConfig.DHCP = "ipv4";
          };
        };
      };
      hardware.wirelessRegulatoryDatabase = true;
    })
  ]);
}
