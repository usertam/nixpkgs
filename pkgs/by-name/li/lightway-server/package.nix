{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libtool,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "lightway-server";
  version = "0-unstable-2025-09-04";

  src = fetchFromGitHub {
    owner = "expressvpn";
    repo = "lightway";
    rev = "4eb836158607c83d47226703de5a043519586782";
    hash = "sha256-sNhTdJTxNxHMVswyzizgBfGbmJhYmMZY/5nVD7ScLjM=";
  };

  cargoHash = "sha256-3/6yEyGntyxxCqrMy2M9dtV2pWiD4M0Rtnb52I4n9nU=";
  cargoDepsName = "lightway";

  cargoBuildFlags = lib.cli.toGNUCommandLine { } {
    package = "lightway-server";
    features = [ "io-uring" ];
  };

  # Some tests rely on debug_assert! and fail in release.
  checkType = "debug";

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
    maintainers = with lib.maintainers; [ usertam ];
  };
}
