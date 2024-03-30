{ lib, ... }: {
  age.secrets = let files = (import ./secrets.nix).files;
                in builtins.foldl' (acc: elem:
                  acc // {
                    "${lib.strings.replaceStrings [ "." ] [ "-" ] elem}".file = ./${elem}.age;
                  }) { } files;
}
