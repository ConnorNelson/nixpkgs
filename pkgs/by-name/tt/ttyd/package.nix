{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  xxd,
  openssl,
  libwebsockets,
  json_c,
  libuv,
  zlib,
  versionCheckHook,
  nixosTests,
}:

let
  libwebsockets' = libwebsockets.overrideAttrs (previousAttrs: {
    # ttyd only uses server APIs; match its upstream libwebsockets build.
    cmakeFlags = previousAttrs.cmakeFlags ++ [
      (lib.cmakeBool "LWS_WITH_SOCKS5" false)
      (lib.cmakeBool "LWS_WITHOUT_CLIENT" true)
      (lib.cmakeBool "LWS_WITH_SECURE_STREAMS" false)
    ];
  });
in

stdenv.mkDerivation (finalAttrs: {
  pname = "ttyd";
  version = "1.7.7";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "tsl0922";
    repo = "ttyd";
    tag = finalAttrs.version;
    hash = "sha256-7e08oBKU7BMZ8328qCfNynCSe7LVZ88+iQZRRKl2YkY=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    xxd
  ];
  buildInputs = [
    openssl
    libwebsockets'
    json_c
    libuv
    zlib
  ];

  outputs = [
    "out"
    "man"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.tests = {
    inherit (nixosTests) ttyd;
  };

  meta = {
    description = "Share your terminal over the web";
    homepage = "https://github.com/tsl0922/ttyd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.thoughtpolice ];
    platforms = lib.platforms.all;
    mainProgram = "ttyd";
  };
})
