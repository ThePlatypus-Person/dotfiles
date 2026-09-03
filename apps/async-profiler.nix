{ lib, stdenv, fetchurl }:

let
    version = "4.3";
in
stdenv.mkDerivation {
    pname = "async-profiler-full";
    inherit version;

    src = fetchurl {
        url = "https://github.com/async-profiler/async-profiler/releases/download/v${version}/async-profiler-${version}-linux-x64.tar.gz";
        hash = "sha256-aaFkYsNMBv9VYY9BZTz/rR+JRoItMIQlEqPg53SEHAY=";
    };

    installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/lib
        cp bin/asprof $out/bin/
        cp bin/jfrconv $out/bin/
        cp lib/libasyncProfiler.so $out/lib/

        runHook postInstall
    '';

    meta = with lib; {
        description = "Sampling profiler for JVM, bundled with jfrconv (not shipped by nixpkgs' async-profiler)";
        homepage = "https://github.com/async-profiler/async-profiler";
        license = licenses.asl20;
        platforms = platforms.linux;
    };
}
