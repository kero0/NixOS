# fix for nixpkgs#480849
final: prev: {
  llvmPackages_18 = prev.llvmPackages_18.overrideScope (
    _llvmFinal: llvmPrev: {
      compiler-rt-libc = llvmPrev.compiler-rt-libc.overrideAttrs (old: {
        cmakeFlags =
          old.cmakeFlags or [ ]
          ++ final.lib.lists.optionals final.stdenv.isDarwin [
            (final.lib.cmakeBool "COMPILER_RT_BUILD_XRAY" false)
            (final.lib.cmakeBool "COMPILER_RT_BUILD_LIBFUZZER" false)
            (final.lib.cmakeBool "COMPILER_RT_BUILD_MEMPROF" false)
            (final.lib.cmakeBool "COMPILER_RT_BUILD_ORC" false)
          ];
      });
    }
  );
}
