nixpkgs:
{
  ipath,
  exclude ? [ ],
}:
let
  inherit (nixpkgs) lib;
  paths = builtins.filter builtins.isPath exclude;
  regexes = builtins.filter builtins.isString exclude;
  isExcluded =
    file:
    builtins.any (p: p == file || lib.path.hasPrefix p file) paths
    || builtins.any (r: builtins.match r (toString file) != null) regexes;
in
builtins.filter (file: lib.hasSuffix ".nix" (toString file) && !isExcluded file) (
  lib.filesystem.listFilesRecursive ipath
)
