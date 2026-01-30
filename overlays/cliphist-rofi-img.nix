final: prev: with prev.lib; {
  cliphist-rofi-img = final.pkgs.stdenv.mkDerivation rec {
    pname = "cliphist-rofi-img";
    version = "unstable-2026-01-26";

    src = final.pkgs.fetchFromGitHub {
      owner = "sentriz";
      repo = "cliphist";
      rev = "bae528ea9fbd9a2b51a71ff2ea0e5ac323ebc542";
      sha256 = "1nlfq5zq8cmbnzcflrlqdz28vjnkx5dkp3637y4lwygv0qv9ijdm";
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
