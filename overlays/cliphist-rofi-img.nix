final: prev:
with prev.lib; {
  cliphist-rofi-img = final.pkgs.stdenv.mkDerivation rec {
    pname = "cliphist-rofi-img";
    version = "0.1.2";

    src = final.pkgs.fetchFromGitHub {
      owner = "sentriz";
      repo = "cliphist";
      rev = "08ee1fbe04610b01c0bd70fb9492f2338e1b9f4d";
      sha256 = "J3kQCFbvDyPb0IjlQvoZt3vxcczaUvpjJU+MOFeLXXY=";
    };

    buildInputs = with final.pkgs; [ cliphist wl-clipboard ];

    installPhase = ''
      mkdir -p $out/bin
      cp $src/contrib/cliphist-rofi-img $out/bin/
    '';

    meta = with final.pkgs.lib.meta; {
      homepage = "";
      description = "";
      license = licenses.gpl3;
      maintainers = [ maintainers.none ];
      platforms = platforms.linux;
    };
  };
}
