final: prev: with prev.lib; {
  cliphist-rofi-img = final.pkgs.stdenv.mkDerivation rec {
    pname = "cliphist-rofi-img";
    version = "unstable-2026-03-09";

    src = final.pkgs.fetchFromGitHub {
      owner = "sentriz";
      repo = "cliphist";
      rev = "a17fb70fdc5a46917c6125ff49c7624491d6bf82";
      sha256 = "025bf98p64gyc9vvayh8y2rv0fwmbx64bixm3aafa48apj7ijr6n";
    };

    buildInputs = with final.pkgs; [
      cliphist
      wl-clipboard
    ];

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
