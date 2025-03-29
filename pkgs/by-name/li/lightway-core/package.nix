{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
  autoconf,
  automake,
  libtool,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "lightway-core";
  version = "0.1.0-unstable-2025-03-26";

  src = fetchFromGitHub {
    owner = "expressvpn";
    repo = "lightway";
    rev = "2e0d9adf5f68e14961f4910929f86090e6e9319e";
    hash = "sha256-sVlAos1OaqzXntQCV8ftFU2VseWHb9aa03GH9Fe6X3M=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-FoMpr59msifEmDvMv1ZmxkxYw7bTc+sbA0c0MlLc0Kw=";

  cargoBuildFlags = [ "--package lightway-core" ];

  # For wolfssl.
  nativeBuildInputs = [
    autoconf
    automake
    libtool
  ];

  meta = with lib; {
    description = "Lightway Core VPN protocol library";
    homepage = "https://expressvpn.com/lightway";
    license = licenses.agpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with maintainers; [ usertam ];
  };
}
