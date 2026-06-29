{ pkgs, self }:
let
  scripts = with pkgs; [
    {
      name = "mk-tang-sd";
      runtimeInputs = [
        coreutils
        zstd
      ];
      inheritPath = false;
      runtimeEnv = {
        image =
          let
            inherit (self.images.tang) name outPath;
          in
          "${outPath}/sd-image/${name}";
      };
    }
  ];
  inherit (builtins) readFile;
  inherit (pkgs) writeShellApplication;
  fold = pkgs.lib.foldr pkgs.lib.recursiveUpdate { };
in
fold (
  map (app: {
    ${app.name} = writeShellApplication ({ text = readFile ./${app.name}; } // app);
  }) scripts
)
