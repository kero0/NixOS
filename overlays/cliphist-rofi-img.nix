final: prev: with prev.lib; {
  cliphist-rofi-img = final.pkgs.stdenv.mkDerivation rec {
    pname = "cliphist-rofi-img";
    version = "unstable-2024-04-13";

    src = final.pkgs.fetchFromGitHub {
      owner = "sentriz";
      repo = "cliphist";
      rev = "faa57e710038f2243a8e7e822bccdd17b2a3b478";
      sha256 = "0xjxidbki32g4mizllnsriqz2yxp37x45rc8s3dj63zgaq410y97";
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
