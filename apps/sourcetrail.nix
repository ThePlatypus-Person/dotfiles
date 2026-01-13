{ lib
, stdenv
, fetchFromGitHub
, cmake
, ninja
, pkg-config
# Qt
, qt6
# Logic/Data
, boost188
, sqlite
, tinyxml
# LLVM/Clang 20
, llvmPackages_20
# Java
, maven
, jdk24
# Testing
, catch2_3
, gtest
, icu
# Wrapper Utilities
, makeWrapper
}:

let
  mavenDeps = stdenv.mkDerivation {
    name = "sourcetrail-java-deps";
    inherit (stdenv.mkDerivation {
      src = fetchFromGitHub {
        owner = "petermost";
        repo = "Sourcetrail";
        rev = "c88503b35821d22fdb0182f929d2ea34bc2132a7";
        fetchSubmodules = true;
        hash = "sha256-vmkbOP+w7/A2srAmaunYtRQpMxGcyqTXFep8gSoJkm4=";
      };
    }) src;

    nativeBuildInputs = [ maven jdk24 ];

    buildPhase = ''
      export JAVA_HOME="${jdk24}"
      mkdir -p $out/repository
      cd java_indexer
      mvn dependency:go-offline -Dmaven.repo.local=$out/repository
      mvn dependency:resolve-plugins -Dmaven.repo.local=$out/repository
    '';

    installPhase = ''
      find $out -name "_remote.repositories" -delete
      find $out -name "*.lastUpdated" -delete
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-RuHq6KMsY/PDKSOtv8dHW7dGpG/moQsXMv5g6WTVzt8=";
  };

  sourcetrail-bin = stdenv.mkDerivation {
    pname = "sourcetrail-bin";
    version = "2025.12.16";

    src = fetchFromGitHub {
      owner = "petermost";
      repo = "Sourcetrail";
      rev = "c88503b35821d22fdb0182f929d2ea34bc2132a7"; 
      fetchSubmodules = true;
      hash = "sha256-vmkbOP+w7/A2srAmaunYtRQpMxGcyqTXFep8gSoJkm4=";
    };

    postPatch = ''
      sed -i '/endif()/a set(headerSourceDir "${llvmPackages_20.libclang.lib}/lib/clang/20/include/")' CMakeLists.txt
      sed -i '/endif()/a set(clangResourcesDir "${llvmPackages_20.libclang.lib}/lib/clang/20/")' CMakeLists.txt
      sed -i 's|Boost::date_time|${boost188.out}/lib/libboost_date_time.so|g' CMakeLists.txt
      sed -i 's|Boost::filesystem|${boost188.out}/lib/libboost_filesystem.so|g' CMakeLists.txt
      sed -i 's|Boost::locale|${boost188.out}/lib/libboost_locale.so|g' CMakeLists.txt
      sed -i 's|Boost::program_options|${boost188.out}/lib/libboost_program_options.so|g' CMakeLists.txt
      sed -i 's|Boost::headers|Boost::headers ${boost188.out}/lib/libboost_chrono.so ${boost188.out}/lib/libboost_thread.so ${boost188.out}/lib/libboost_atomic.so|g' CMakeLists.txt
      substituteInPlace java_indexer/CMakeLists.txt \
        --replace-fail '"''${MVN_COMMAND}" package' \
        '"''${MVN_COMMAND}" package --offline "-Dmaven.repo.local=/build/maven_repo"'
      patchShebangs .
    '';

    nativeBuildInputs = [ cmake ninja pkg-config qt6.wrapQtAppsHook maven jdk24 ];
    buildInputs = [ qt6.qtbase qt6.qtsvg boost188 sqlite tinyxml icu llvmPackages_20.libclang llvmPackages_20.llvm llvmPackages_20.clang catch2_3 gtest ];

    preConfigure = ''
      export JAVA_HOME="${jdk24}"
      export CLANG_RESOURCES_PATH="${llvmPackages_20.libclang.lib}/lib/clang/20/include"
      REAL_REPO_ROOT=$(find ${mavenDeps} -name "org" -type d -print -quit | sed 's|/org$||')
      mkdir -p /build/maven_repo
      cp -rL "$REAL_REPO_ROOT/." /build/maven_repo/
      chmod -R +w /build/maven_repo
    '';

    cmakeFlags = [
      "-DBUILD_TESTING=OFF"
      "-DCMAKE_BUILD_TYPE=Release"
      "-DBUILD_CXX_LANGUAGE_PACKAGE=ON"
      "-DBUILD_JAVA_LANGUAGE_PACKAGE=ON"
      "-DJAVA_AWT_LIBRARY=${jdk24}/lib/libawt.so"
      "-DJAVA_JVM_LIBRARY=${jdk24}/lib/server/libjvm.so"
      "-DJAVA_INCLUDE_PATH=${jdk24}/include"
      "-DJAVA_INCLUDE_PATH2=${jdk24}/include/linux"
    ];

    configurePhase = ''
      runHook preConfigure
      cmake --preset system-release -G Ninja $cmakeFlags
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      cmake --build /build/build/system-release -j $NIX_BUILD_CORES
      runHook postBuild
    '';

    installPhase = ''
      mkdir -p $out/share/sourcetrail
      cmake --install /build/build/system-release --prefix $out
    '';

    meta = with lib; {
      description = "Visual source explorer for C/C++ and Java";
      homepage = "https://github.com/petermost/Sourcetrail";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
    };
  };
in
stdenv.mkDerivation {
  pname = "sourcetrail";
  inherit (sourcetrail-bin) version meta;

  nativeBuildInputs = [ qt6.wrapQtAppsHook makeWrapper ];
  buildInputs = [ qt6.qtbase ];

  unpackPhase = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/Sourcetrail/app

    # Link all files/folders from the original app directory
    # Except 'data', which we need to make writable to insert our theme
    for item in ${sourcetrail-bin}/Sourcetrail/app/*; do
      filename=$(basename "$item")
      if [ "$filename" != "data" ]; then
        ln -s "$item" "$out/Sourcetrail/app/$filename"
      fi
    done

    # Create a real 'data' directory structure
    mkdir -p $out/Sourcetrail/app/data
    for item in ${sourcetrail-bin}/Sourcetrail/app/data/*; do
      filename=$(basename "$item")
      if [ "$filename" != "color_schemes" ]; then
        ln -s "$item" "$out/Sourcetrail/app/data/$filename"
      fi
    done

    # Create a real 'color_schemes' directory
    mkdir -p $out/Sourcetrail/app/data/color_schemes
    # Link original schemes back in
    ln -s ${sourcetrail-bin}/Sourcetrail/app/data/color_schemes/* $out/Sourcetrail/app/data/color_schemes/

    #  Inject the Hot-Edit link
    ln -s "/home/mori/dotfiles/apps/tokyo_night_dark.xml" "$out/Sourcetrail/app/data/color_schemes/tokyo_night_dark.xml"

    # Link binaries
    ln -s $out/Sourcetrail/app/Sourcetrail $out/bin/Sourcetrail
    ln -s $out/Sourcetrail/app/sourcetrail_indexer $out/bin/sourcetrail_indexer

    # Wrap for environment
    wrapProgram $out/bin/Sourcetrail \
      --set JAVA_HOME "${jdk24}" \
      --set CLANG_RESOURCES_PATH "${llvmPackages_20.libclang.lib}/lib/clang/20/include"
    
    runHook postInstall
  '';
}
