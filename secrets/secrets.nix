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
  keys = filter (s: isString s && stringLength s > 0) (split "\n" (readFile ./keys));
  files = [ "nix.conf" ];
in
foldl' (acc: elem: acc // { "${elem}.age".publicKeys = keys; }) { } files
