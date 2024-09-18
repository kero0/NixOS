final: prev: with prev.lib; {
  cliphist-rofi-img = final.pkgs.stdenv.mkDerivation rec {
    pname = "cliphist-rofi-img";
    version = "unstable-2024-09-12";

    src = final.pkgs.fetchFromGitHub {
      owner = "sentriz";
      repo = "cliphist";
      rev = "c49dcd26168f704324d90d23b9381f39c30572bd";
      sha256 = "0xnhilnyjkrb29j80rx91w13145x3hq0441wwrm8rwc56zjgjsfs";
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
