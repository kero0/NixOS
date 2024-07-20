{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    nixGLPrefix = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Will be prepended to commands which require working OpenGL.

        This needs to be set to the right nixGL package on non-NixOS systems.
      '';
    };
    nixGL = lib.mkOption {
      default =
        # Wrap a single package
        pkg:

        if config.nixGLPrefix == "" then
          pkg
        else
          # Wrap the package's binaries with nixGL, while preserving the rest of
          # the outputs and derivation attributes.
          (pkg.overrideAttrs (old: {
            name = "nixGL-${pkg.name}";
            buildCommand = ''
              set -eo pipefail

              ${
                # Heavily inspired by https://stackoverflow.com/a/68523368/6259505
                pkgs.lib.concatStringsSep "\n" (
                  map (outputName: ''
                    echo "Copying output ${outputName}"
                    set -x
                    cp -rs --no-preserve=mode "${pkg.${outputName}}" "''$${outputName}"
                    set +x
                  '') (old.outputs or [ "out" ])
                )
              }

              rm -rf $out/bin/*
              shopt -s nullglob # Prevent loop from running if no files
              for file in ${pkg.out}/bin/*; do
                echo "#!${pkgs.bash}/bin/bash" > "$out/bin/$(basename $file)"
                echo "exec -a \"\$0\" ${config.nixGLPrefix} $file \"\$@\"" >> "$out/bin/$(basename $file)"
                chmod +x "$out/bin/$(basename $file)"
              done
              shopt -u nullglob # Revert nullglob back to its normal default state
            '';
          }));
    };
  };
  config = {
    nixGLPrefix = pkgs.nixgl.nixGLIntel + /bin/nixGLIntel;
  };
}
