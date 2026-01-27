{ lib, ... }:
let
  inherit (lib)
    attrNames
    map
    mergeAttrsList
    pipe
    replaceStrings
    ;
  mkSecret = f: {
    ${replaceStrings [ ".age" "." ] [ "" "-" ] f}.file = ./${f};
  };
in
{
  age.secrets = pipe ./secrets.nix [
    import
    attrNames
    (map mkSecret)
    mergeAttrsList
  ];
}
