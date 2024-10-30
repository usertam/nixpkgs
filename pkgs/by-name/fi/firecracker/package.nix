{
  lib,
  stdenv,
  fetchFromGitHub,
  makeRustPlatform,
  rustc,
  cargo,
  llvmPackages,
  cmake,
  gcc,

  # gcc compile error at deps: aws-lc-sys, function 'memcpy' inlined from 'OPENSSL_memcpy'
  # error: '__builtin_memcpy' specified bound exceeds maximum object size
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=91397
  useRustPlatform ? makeRustPlatform {
    inherit rustc cargo;
    inherit (llvmPackages) stdenv;
  }
}:

useRustPlatform.buildRustPackage rec {
  pname = "firecracker";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "firecracker-microvm";
    repo = "firecracker";
    rev = "v${version}";
    hash = "sha256-NgT06Xfb6j+d5EcqFjQeaiY08uJJjmrddzdwSoqpKbQ=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";
  cargoLock.outputHashes."micro_http-0.1.0" = "sha256-bso39jUUyhlNutUxHw8uHtKWQIHmoikfQ5O3RIePboo=";

  nativeBuildInputs = [
    cmake
    gcc
    useRustPlatform.bindgenHook
  ];

  cargoBuildFlags = [
    "--workspace"
  ];

  checkFlags = [
    "--skip test_read_valid_sysfs_file"     # requires /sys/devices/virtual/dmi
    "--skip test_dump"                      # requires /dev/kvm
    "--skip test_fingerprint_dump_command"
    "--skip test_template_dump_command"
    "--skip test_template_verify_command"
    "--skip test_build_microvm"
    "--skip test_filter_apply"              # requires seccomp == 0
  ];

  installPhase = ''
    mkdir -p $out/bin
    releaseDir="build/cargo_target/${stdenv.hostPlatform.rust.rustcTarget}/release"
    for bin in $(find $releaseDir -maxdepth 1 -type f -executable); do
      install -Dm555 -t $out/bin $bin
    done
  '';

  meta = with lib; {
    description = "Secure, fast, minimal micro-container virtualization";
    homepage = "http://firecracker-microvm.io";
    changelog = "https://github.com/firecracker-microvm/firecracker/releases/tag/v${version}";
    mainProgram = "firecracker";
    license = licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = with maintainers; [
      usertam
      thoughtpolice
      qjoly
      techknowlogick
    ];
  };
}
