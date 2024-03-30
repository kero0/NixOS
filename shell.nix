{ pkgs }:
with pkgs;
let
  xmonad-xmobar-ghc = haskellPackages.ghcWithPackages (ps:
    with ps; [
      regex-compat
      xmonad
      xmonad-contrib

      hlint
      stylish-haskell
      haskell-language-server
    ]);

  #qtile stuff
  mypy = python3.withPackages (p: with p; [ autopep8 black mypy python qtile ]);

in mkShell {
  buildInputs = [
    # formatting stuff
    nixpkgs-fmt
    shfmt
    # other generally needed stuff
    git
    ripgrep
  ] ++ (if pkgs.stdenv.hostPlatform.isDarwin then
    [ ]
  else [
    xmonad-xmobar-ghc
    mypy
  ]);
  shellHook = if pkgs.stdenv.hostPlatform.isDarwin then
    ""
  else ''
    eval $(egrep ^export ${xmonad-xmobar-ghc}/bin/ghc)
    export PYTHONPATH=${mypy}/lib/python${mypy.pythonVersion}/site-packages
  '';
}
