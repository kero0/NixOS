{
  nixpkgs,
  self,
}:
nixpkgs.lib.attrsets.concatMapAttrs (host: config: {
  ${host} = config.pkgs.writeShellScriptBin "${host}" ''
    [ -z "$QEMU_NET_OPTS" ] && export QEMU_NET_OPTS="hostfwd=tcp::2221-:22"
    exec ${config.config.system.build.vmWithBootLoader}/bin/run-${host}-vm "$@"
  '';
}) self.nixosConfigurations
