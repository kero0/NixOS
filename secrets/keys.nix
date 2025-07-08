let
  inherit (builtins)
    filter
    isString
    readFile
    stringLength
    split
    ;
in
filter (s: isString s && stringLength s > 0) (split "\n" (readFile ./keys))
