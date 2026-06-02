# fix for nixpkgs#516392
final: prev: {
  openldap =
    if final.stdenv.hostPlatform.system == "i686-linux" then
      prev.openldap.overrideAttrs (_: {
        doCheck = false;
      })
    else
      prev.openldap;
}
