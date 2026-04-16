final: _: {
  cliphist-rofi-img = final.pkgs.stdenv.mkDerivation {
    pname = "cliphist-rofi-img";

    inherit (final.pkgs.cliphist) meta src version;

    buildInputs = with final.pkgs; [
      cliphist
      wl-clipboard
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp $src/contrib/cliphist-rofi-img $out/bin/
    '';
  };
}
