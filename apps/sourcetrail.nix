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

	# Run maven to fetch dependencies into a local folder
	buildPhase = ''
	    export JAVA_HOME="${jdk24}"

	    # Create a specific repository folder
	    mkdir -p $out/repository
	    cd java_indexer

	    mvn dependency:go-offline -Dmaven.repo.local=$out/repository
	    mvn dependency:resolve-plugins -Dmaven.repo.local=$out/repository
	'';

	# We only care about the downloaded artifacts
	installPhase = ''
	    find $out -name "_remote.repositories" -delete
	    find $out -name "*.lastUpdated" -delete
	'';

	outputHashAlgo = "sha256";
	outputHashMode = "recursive";
	outputHash = "sha256-RuHq6KMsY/PDKSOtv8dHW7dGpG/moQsXMv5g6WTVzt8=";
    };
in
stdenv.mkDerivation {
    pname = "sourcetrail";
    version = "2025.12.16";

    src = fetchFromGitHub {
	owner = "petermost";
	repo = "Sourcetrail";
	rev = "c88503b35821d22fdb0182f929d2ea34bc2132a7"; 
	fetchSubmodules = true;
	hash = "sha256-vmkbOP+w7/A2srAmaunYtRQpMxGcyqTXFep8gSoJkm4=";
    };

    postPatch = ''
	# Fix Clang header paths in Sourcetrail's logic
	sed -i '/endif()/a set(headerSourceDir "${llvmPackages_20.libclang.lib}/lib/clang/20/include/")' CMakeLists.txt
	sed -i '/endif()/a set(clangResourcesDir "${llvmPackages_20.libclang.lib}/lib/clang/20/")' CMakeLists.txt

	# Brute-force Boost targets to absolute Nix store paths
	sed -i 's|Boost::date_time|${boost188.out}/lib/libboost_date_time.so|g' CMakeLists.txt
	sed -i 's|Boost::filesystem|${boost188.out}/lib/libboost_filesystem.so|g' CMakeLists.txt
	sed -i 's|Boost::locale|${boost188.out}/lib/libboost_locale.so|g' CMakeLists.txt
	sed -i 's|Boost::program_options|${boost188.out}/lib/libboost_program_options.so|g' CMakeLists.txt

	# Manually inject missing transitive dependencies (fix linker error)
	sed -i 's|Boost::headers|Boost::headers ${boost188.out}/lib/libboost_chrono.so ${boost188.out}/lib/libboost_thread.so ${boost188.out}/lib/libboost_atomic.so|g' CMakeLists.txt

	# Patch the Java indexer Maven call
	substituteInPlace java_indexer/CMakeLists.txt \
	    --replace-fail '"''${MVN_COMMAND}" package' \
	    '"''${MVN_COMMAND}" package --offline "-Dmaven.repo.local=/build/maven_repo"'
	
	# Patch the Java indexer Maven call with the ABSOLUTE path

	patchShebangs .
	'';

    nativeBuildInputs = [
	cmake
	ninja
	pkg-config
	qt6.wrapQtAppsHook
	maven
	jdk24
    ];

    buildInputs = [
	qt6.qtbase
	qt6.qtsvg
	boost188
	sqlite
	tinyxml
	icu
	llvmPackages_20.libclang
	llvmPackages_20.llvm
	llvmPackages_20.clang
	catch2_3
	gtest
    ];

    # Sourcetrail needs to know where Clang headers are to index code correctly
    preConfigure = ''
	export JAVA_HOME="${jdk24}"
	export CLANG_RESOURCES_PATH="${llvmPackages_20.libclang.lib}/lib/clang/20/include"

	echo "Locating Maven repository root..."
	# Find the directory containing the 'org' folder inside mavenDeps
	REAL_REPO_ROOT=$(find ${mavenDeps} -name "org" -type d -print -quit | sed 's|/org$||')

	if [ -z "$REAL_REPO_ROOT" ]; then
	    echo "Error: Could not find Maven artifacts in mavenDeps!"
	    exit 1
	fi

	echo "Detected repository root at: $REAL_REPO_ROOT"
	mkdir -p /build/maven_repo

	# Copy using -L to follow symlinks and -p to preserve what we can
	cp -rL "$REAL_REPO_ROOT/." /build/maven_repo/
	chmod -R +w /build/maven_repo
    '';

    cmakeFlags = [
	"-DBUILD_TESTING=OFF"
	"-DCMAKE_BUILD_TYPE=Release"
	"-DBUILD_CXX_LANGUAGE_PACKAGE=ON"
	"-DBUILD_JAVA_LANGUAGE_PACKAGE=ON"

	# JNI/Java Linker fixes
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
	runHook preInstall

	mkdir -p $out/bin $out/share/sourcetrail
	cmake --install /build/build/system-release --prefix $out
	cd $out/bin
	ln -s ../Sourcetrail/app/Sourcetrail Sourcetrail
	ln -s ../Sourcetrail/app/sourcetrail_indexer sourcetrail_indexer
	cd -

	TARGET_DIR="$out/Sourcetrail/app/data/color_schemes"
	mkdir -p "$TARGET_DIR"
	#cp ${./tokyo_night_dark.xml} "$TARGET_DIR/tokyo_night_dark.xml"
	ln -s "/home/mori/dotfiles/apps/tokyo_night_dark.xml" "$TARGET_DIR/tokyo_night_dark.xml"

	runHook postInstall
    '';

    meta = with lib; {
	description = "Visual source explorer for C/C++ and Java";
	homepage = "https://github.com/petermost/Sourcetrail";
	license = licenses.gpl3Plus;
	platforms = platforms.linux;
    };
}
