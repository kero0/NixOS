final: prev: with prev.lib; {
  cliphist-rofi-img = final.pkgs.stdenv.mkDerivation rec {
    pname = "cliphist-rofi-img";
    version = "unstable-2025-09-11";

    src = final.pkgs.fetchFromGitHub {
      owner = "sentriz";
      repo = "cliphist";
      rev = "6eda526d02119ebc09ec0f64b0a96ed4540f5a83";
      sha256 = "1mbkw4vzyw775pbnsp9adj0vs3iq86f3g7yq42qgy994lspsg48v";
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
