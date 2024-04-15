nixpkgs:
let
  umport =
    { ipath ? null
    , exclude ? [ ]
    , recursive ? true
    ,
    }:
      with nixpkgs.lib;
      with nixpkgs.lib.path;
      with nixpkgs.lib.fileset; let
        excludedFiles = filter (f: pathIsRegularFile f) exclude;
        excludedDirs = filter (d: pathIsDirectory d) exclude;
        isExcluded = f:
          if elem f excludedFiles
          then true
          else builtins.foldl' (acc: f': acc || hasPrefix f' f) false excludedDirs;
	in
	filter
          (file: pathIsRegularFile file && hasSuffix ".nix" (builtins.toString file) && !isExcluded file)
          (filesystem.listFilesRecursive ipath);
  in
  umport
