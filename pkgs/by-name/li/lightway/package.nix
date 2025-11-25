{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libtool,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "lightway";
  version = "0-unstable-2025-11-25";

  src = fetchFromGitHub {
    owner = "expressvpn";
    repo = "lightway";
    rev = "15816afd57e43325c2c0f7d3c110686522280e97";
    hash = "sha256-WwgAoScrX3h3oOHN1+dEjyvJdcF1P21d5Jg2FJFttWU=";
  };

  cargoHash = "sha256-gK4Zuna2W4YI/EZGYUv9EctWa0BPvGoHnDWzdMgCmWg=";

  cargoBuildFlags = lib.cli.toCommandLineGNU { } {
    package = [
      "lightway-client"
      "lightway-server"
    ];

    features = lib.optionals stdenv.hostPlatform.isLinux [
      "io-uring"
    ];
  };

  # Enable ARM crypto extensions, overrides the default stdenv.hostPlatform.gcc.arch.
  env.NIX_CFLAGS_COMPILE =
    with stdenv.hostPlatform;
    lib.optionalString (isAarch && isLinux) "-march=${gcc.arch}+crypto";

  # For wolfSSL.
  nativeBuildInputs = [
    autoconf
    automake
    libtool
    rustPlatform.bindgenHook
  ];

  meta = {
    description = "A modern VPN protocol in Rust";
    homepage = "https://expressvpn.com/lightway";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [
      dustyhorizon
      usertam
    ];
    platforms = with lib.platforms; darwin ++ linux;
    mainProgram = "lightway-client";
  };
}
