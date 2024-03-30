final: prev:
with prev.lib; {
  cyrus_sasl_xoauth2 = prev.stdenv.mkDerivation rec {
    name = "cyrus-sasl-xoauth2";
    src = prev.fetchFromGitHub {
      owner = "moriyoshi";
      repo = "cyrus-sasl-xoauth2";
      rev = "36aabca54fd65c8fa7a707cb4936751599967904";
      sha256 = "OlmHuME9idC0fWMzT4kY+YQ43GGch53snDq3w5v/cgk=";
    };

    outputs = [ "out" ];

    depsBuildBuild = with final; [ buildPackages.stdenv.cc cyrus_sasl ];
    nativeBuildInputs = with final;
      [ autoreconfHook ]
      ++ optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;
    buildInputs = with final;
      [ openssl db gettext libkrb5 ] ++ optional stdenv.isLinux pam;

    configureFlags = [
      "--with-openssl=${final.openssl.dev}"
      "--with-cyrus-sasl=${placeholder "out"}"
      "--with-plugindir=${placeholder "out"}/lib/sasl2"
      "--with-saslauthd=/run/saslauthd"
      "--enable-login"
      "--enable-shared"
    ];

    installFlags = optional prev.stdenv.isDarwin
      [ "framedir=$(out)/Library/Frameworks/SASL2.framework" ];

    # Make autoreconfHook happy
    postPatch = ''
      touch NEWS AUTHORS ChangeLog
    '';

    meta = with prev.lib; {
      description = "Cyrus SASL XOAUTH2 plugin";
      homepage = "https://github.com/moriyoshi/cyrus-sasl-xoauth2";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
}
