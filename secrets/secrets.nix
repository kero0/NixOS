let
  inherit (builtins)
    split
    readFile
    filter
    isString
    stringLength
    foldl'
    ;
  # to update keys, I run "curl https://github.com/kero0.keys -o keys"
  keys = import ./keys.nix;
  files = [
    "nix.conf"
    "ssh-config-private"
  ];
in
foldl' (acc: elem: acc // { "${elem}.age".publicKeys = keys; }) { } files
