nixpkgs:
{
  ipath,
  exclude ? [ ],
}:
with nixpkgs.lib;
with nixpkgs.lib.path;
with nixpkgs.lib.fileset;
let
  excludedFiles = filter pathIsRegularFile exclude;
  excludedDirs = filter pathIsDirectory exclude;
  isExcluded = f: elem f excludedFiles || any (flip hasPrefix f) excludedDirs;
in
filter (
  file: pathIsRegularFile file && hasSuffix ".nix" (builtins.toString file) && !isExcluded file
) (filesystem.listFilesRecursive ipath)
