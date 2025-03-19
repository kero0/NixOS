{
  config,
  lib,
  pkgs,
  ...
}:
{
  system.activationScripts.sudo-fingerprint.text =
    let
      fingerprint_command = "auth sufficient pam_tid.so";
      file = "/etc/pam.d/sudo";
    in
    ''
      #!/bin/sh
      set -euo pipefail
      if grep -q '${fingerprint_command}' '${file}'; then
        echo "Fingerprint authentication already enabled in ${file}"
      else
        TMPFILE=$(mktemp)
        echo '${fingerprint_command}' > $TMPFILE
        cat ${file} >> $TMPFILE
        cat $TMPFILE > ${file}
        rm $TMPFILE
        echo "Fingerprint authentication enabled in ${file}"
      fi
    '';
}
