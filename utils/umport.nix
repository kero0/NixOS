nixpkgs:
{
  ipath,
  exclude ? [ ],
}:
with nixpkgs.lib;
with nixpkgs.lib.path;
with nixpkgs.lib.fileset;
let
  excludedFiles = filter (f: isPath f && pathIsRegularFile f) exclude;
  excludedDirs = filter (f: isPath f && pathIsDirectory f) exclude;
  excludedRegexes = path: any (r: null != match r (toString path)) (filter (f: !isPath f) exclude);
  isExcluded = f: elem f excludedFiles || any (flip hasPrefix f) excludedDirs || excludedRegexes f;
in
filter (
  file: pathIsRegularFile file && hasSuffix ".nix" (builtins.toString file) && !isExcluded file
) (filesystem.listFilesRecursive ipath)
