{ lib, config, ... }: {
  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "${config.my.user.homedir}/.ssh/id_ed25519"
    ];
    secrets =
      let files = (import ./secrets.nix).files;
      in builtins.foldl'
        (acc: elem:
          acc // {
            "${lib.strings.replaceStrings [ "." ] [ "-" ] elem}".file = ./${elem}.age;
          })
        { }
        files;
  };
}
