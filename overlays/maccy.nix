final: prev:
with prev.lib; {
  maccy = final.pkgs.stdenv.mkDerivation rec {
    name = "maccy-${version}";
    version = "0.26.2";

    src = final.pkgs.fetchzip {
      url =
        "https://github.com/p0deje/Maccy/releases/download/${version}/Maccy.app.zip";
      sha256 = "PPE+dtlwPOngBeUTgnziGBdKVdNgUQqWVbeBEYSgCIs=";
    };

    # buildInputs = with final.pkgs; [ cmake qt5 xorg.libX11 ];

    installPhase = ''
      mkdir -p $out/Applications/Maccy.app
       cp -r $src/. $out/Applications/Maccy.app/
    '';

    meta = with final.pkgs.lib.meta; {
      homepage = "https://maccy.app/";
      description = "A lightweight clipboard manager for macOS.";
      license = licenses.mit;
      maintainers = [ maintainers.none ];
      platforms = platforms.darwin;
    };
  };
}
