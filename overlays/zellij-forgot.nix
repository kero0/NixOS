final: prev:
let
  pkgs = final.pkgsCross.wasi32;
in
{
  zellijPlugins = prev.zellijPlugins // {
    zellij-forgot = prev.zellijPlugins.wrapper "zellij-forgot" (
      pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        pname = "zellij-forgot";
        version = "0.4.2";

        src = final.fetchFromGitHub {
          owner = "karimould";
          repo = "zellij-forgot";
          tag = finalAttrs.version;
          hash = "sha256-QS09lC6yyUZA13PHERrdY/phfo1QoHAmRPpQUGL3pP8=";
        };

        nativeBuildInputs = [ pkgs.lld ];
        env.RUSTFLAGS = " -C linker=wasm-ld";

        cargoHash = "sha256-GR3bg6Rf6opb0jh8Hyv1y7gpsBh8nRExPjcGzIafHXg=";

        meta = {
          description = "Remember your keybinds and all the other things";
          homepage = "https://github.com/karimould/zellij-forgot";
          changelog = "https://github.com/karimould/zellij-forgot/releases/tag/${finalAttrs.src.tag}";
          license = final.lib.licenses.mit;
        };
      })
    );
  };
}
