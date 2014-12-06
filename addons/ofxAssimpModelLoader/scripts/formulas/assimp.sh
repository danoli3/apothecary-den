#! /bin/bash
#
# Open Asset Import Library
# cross platform 3D model loader
# https://github.com/assimp/assimp
#
# uses CMake

# define the version
VER=3.1.1

# tools for git use
GIT_URL=
# GIT_URL=https://github.com/assimp/assimp.git
GIT_TAG=

FORMULA_TYPES=( "osx" "osx-clang-libc++" "ios" )

# download the source code and unpack it into LIB_NAME
function download() {

	# stable release from source forge
	curl -LO "https://github.com/assimp/assimp/archive/v$VER.zip"
	unzip -oq "v$VER.zip"
	mv "assimp-$VER" assimp
	rm "v$VER.zip"

    # fix an issue with static libs being disabled - see issue https://github.com/assimp/assimp/issues/271
    # this could be fixed fairly soon - so see if its needed for future releases.
    sed -i -e 's/SET ( ASSIMP_BUILD_STATIC_LIB OFF/SET ( ASSIMP_BUILD_STATIC_LIB ON/g' assimp/CMakeLists.txt
    sed -i -e 's/option ( BUILD_SHARED_LIBS "Build a shared version of the library" ON )/option ( BUILD_SHARED_LIBS "Build a shared version of the library" OFF )/g' assimp/CMakeLists.txt
}

# prepare the build environment, executed inside the lib src dir
function prepare() {

    rm -f CMakeCache.txt || true

    # we don't use the build script for iOS now as it is less reliable than doing it our self
	if [ "$TYPE" == "ios" ] ; then
		# ref: http://stackoverflow.com/questions/6691927/how-to-build-assimp-library-for-ios-device-and-simulator-with-boost-library

        export TOOLCHAIN=$XCODE_DEV_ROOT/Toolchains/XcodeDefault.xctoolchain
		export TARGET_IOS
        
        local IOS_ARCHS="i386 x86_64 armv7 arm64" #armv7s
        local STDLIB="libc++"
        local CURRENTPATH=`pwd`

		SDKVERSION=`xcrun -sdk iphoneos --show-sdk-version`	
        DEVELOPER=$XCODE_DEV_ROOT
		TOOLCHAIN=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain
		VERSION=$VER

        # Validate environment
        case $XCODE_DEV_ROOT in
            *\ * )
                echo "Your Xcode path contains whitespaces, which is not supported."
                exit 1
                ;;
        esac
        case $CURRENTPATH in
            *\ * )
                echo "Your path contains whitespaces, which is not supported by 'make install'."
                exit 1
                ;;
        esac

        mkdir -p "builddir/$TYPE"

        local buildOpts="-DASSIMP_BUILD_STATIC_LIB=1 -DASSIMP_BUILD_SHARED_LIB=0 -DASSIMP_ENABLE_BOOST_WORKAROUND=1"
        libsToLink=""

        # loop through architectures! yay for loops!
        for IOS_ARCH in ${IOS_ARCHS}
        do
        	unset ARCH IOS_DEVROOT IOS_SDKROOT IOS_CC TARGET_NAME HEADER
            unset CC CPP CXX CXXCPP CFLAGS CXXFLAGS LDFLAGS LD AR AS NM RANLIB LIBTOOL 
            unset EXTRA_PLATFORM_CFLAGS EXTRA_PLATFORM_LDFLAGS IOS_PLATFORM NO_LCMS

            export CC=$TOOLCHAIN/usr/bin/clang
			export CPP=$TOOLCHAIN/usr/bin/clang++
			export CXX=$TOOLCHAIN/usr/bin/clang++
			export CXXCPP=$TOOLCHAIN/usr/bin/clang++
	
			export LD=$TOOLCHAIN/usr/bin/ld
			export AR=$TOOLCHAIN/usr/bin/ar
			export AS=$TOOLCHAIN/usr/bin/as
			export NM=$TOOLCHAIN/usr/bin/nm
			export RANLIB=$TOOLCHAIN/usr/bin/ranlib
			export LIBTOOL=$TOOLCHAIN/usr/bin/libtool

            echo "Building $curArch "

            local EXTRA_PLATFORM_CFLAGS=""
			export EXTRA_PLATFORM_LDFLAGS=""
			if [[ "${IOS_ARCH}" == "i386" || "${IOS_ARCH}" == "x86_64" ]];
			then
				PLATFORM="iPhoneSimulator"
			
			else
				PLATFORM="iPhoneOS"
			fi

			export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
			export CROSS_SDK="${PLATFORM}${SDKVERSION}.sdk"
			export BUILD_TOOLS="${DEVELOPER}"

           
            MIN_IOS_VERSION=$IOS_MIN_SDK_VER
		    # min iOS version for arm64 is iOS 7
		
		    if [[ "${IOS_ARCH}" == "arm64" || "${IOS_ARCH}" == "x86_64" ]]; then
		    	MIN_IOS_VERSION=7.0 # 7.0 as this is the minimum for these architectures
		    elif [ "${IOS_ARCH}" == "i386" ]; then
		    	MIN_IOS_VERSION=5.1 # 6.0 to prevent start linking errors
		    fi

		    MIN_TYPE=-miphoneos-version-min=
		    if [[ "${IOS_ARCH}" == "i386" || "${IOS_ARCH}" == "x86_64" ]]; then
		    	MIN_TYPE=-mios-simulator-version-min=
		    fi

			export EXTRA_PLATFORM_CFLAGS="$EXTRA_PLATFORM_CFLAGS"
		    export EXTRA_PLATFORM_LDFLAGS="$EXTRA_PLATFORM_LDFLAGS -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -Wl,-dead_strip -I${CROSS_TOP}/SDKs/${CROSS_SDK}/usr/include/ $MIN_TYPE$MIN_IOS_VERSION "

		    EXTRA_LINK_FLAGS="-arch $IOS_ARCH -Os -DHAVE_UNISTD_H=1 -DNDEBUG -fPIC -L$CROSS_SDK/usr/lib/ "
			EXTRA_FLAGS="$EXTRA_LINK_FLAGS -funroll-loops -ffast-math $MIN_TYPE$MIN_IOS_VERSION -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -I${CROSS_TOP}/SDKs/${CROSS_SDK}/usr/include/"

          
            export LDFLAGS="$EXTRA_LINK_FLAGS"
            export DEVROOT="$CROSS_TOP"
            export SDKROOT="$CROSS_SDK"
            export CFLAGS="$EXTRA_FLAGS"
            export CPPFLAGS="$EXTRA_FLAGS"
            export CXXFLAGS="$EXTRA_FLAGS"

            #echo " out c_flags are $OUR_CFLAGS "

            cmake -G 'Unix Makefiles' $buildOpts -DCMAKE_C_FLAGS="$EXTRA_FLAGS" -DCMAKE_CXX_FLAGS="$EXTRA_FLAGS" -DCMAKE_CXX_FLAGS="$EXTRA_FLAGS".

            make clean
            make assimp -j 8 -l

            fileToRenameTo="./lib/libassimp-$TYPE-$curArch.a"

            mv ./lib/libassimp.a $fileToRenameTo

            libsToLink="$libsToLink $fileToRenameTo"

            make clean

        done

		# link into universal lib
		command="lipo -create $libsToLink -o lib/libassimp-ios.a"
        $command || true
	fi

	if [ "$TYPE" == "osx" ] ; then

		# warning, assimp on github uses the ASSIMP_ prefix for CMake options ...
		# these may need to be updated for a new release
		local buildOpts="--build build/$TYPE -DASSIMP_BUILD_STATIC_LIB=1 -DASSIMP_BUILD_SHARED_LIB=0 -DASSIMP_ENABLE_BOOST_WORKAROUND=1"

		# 32 bit
		cmake -G 'Unix Makefiles' $buildOpts -DCMAKE_C_FLAGS="-arch i386 -O3 -DNDEBUG -funroll-loops" -DCMAKE_CXX_FLAGS="-arch i386 -stdlib=libstdc++ -O3 -DNDEBUG -funroll-loops" .
		make assimp
		mv lib/libassimp.a lib/libassimp-osx-i386.a
		make clean

		# 64 bit
		cmake -G 'Unix Makefiles' $buildOpts -DCMAKE_C_FLAGS="-arch x86_64 -O3 -DNDEBUG -funroll-loops" -DCMAKE_CXX_FLAGS="-arch x86_64 -stdlib=libc++ -O3 -DNDEBUG -funroll-loops" .
		make assimp 
		mv lib/libassimp.a lib/libassimp-osx-x86_64.a
		make clean

		# link into universal lib
		lipo -c lib/libassimp-osx-i386.a lib/libassimp-osx-x86_64.a -o lib/libassimp-osx.a

	elif [ "$TYPE" == "osx-clang-libc++" ] ; then
		echoWarning "WARNING: this needs to be updated - do we even need it anymore?"

		# warning, assimp on github uses the ASSIMP_ prefix for CMake options ...
		# these may need to be updated for a new release
		local buildOpts="--build build/$TYPE"

		export CPP=`xcrun -find clang++`
		export CXX=`xcrun -find clang++`
		export CXXCPP=`xcrun -find clang++`
		export CC=`xcrun -find clang`
		
		# 32 bit
		cmake -G 'Unix Makefiles' $buildOpts -DCMAKE_C_FLAGS="-arch i386 $assimp_flags" -DCMAKE_CXX_FLAGS="-arch i386 -std=c++11 -stdlib=libc++ $assimp_flags" .
		make assimp -j 
		mv lib/libassimp.a lib/libassimp-i386.a
		make clean

		# rename lib
		libtool -c lib/libassimp-i386.a -o lib/libassimp-osx.a

	elif [ "$TYPE" == "linux" ] ; then
		echoWarning "TODO: linux build"

	elif [ "$TYPE" == "linux64" ] ; then
		echoWarning "TODO: linux64 build"

	elif [ "$TYPE" == "vs" ] ; then
		echoWarning "TODO: vs build"

	elif [ "$TYPE" == "win_cb" ] ; then
		echoWarning "TODO: win_cb build"

	elif [ "$TYPE" == "android" ] ; then
		echoWarning "TODO: android build"
	fi
}

# executed inside the lib src dir, first arg $1 is the dest libs dir root
function copy() {

	# headers
	mkdir -p $1/include
    rm -r $1/include/assimp || true
    rm -r $1/include/* || true
	cp -Rv include/* $1/include

	# libs
	mkdir -p $1/lib/$TYPE
	if [ "$TYPE" == "vs" ] ; then
		cp -Rv lib/libassimp.lib $1/lib/$TYPE/assimp.lib
	elif [ "$TYPE" == "osx" ] ; then
		cp -Rv lib/libassimp-osx.a $1/lib/$TYPE/assimp.a
	elif [ "$TYPE" == "ios" ] ; then
		cp -Rv lib/libassimp-ios.a $1/lib/$TYPE/assimp.a
	else
		cp -Rv lib/libassimp.a $1/lib/$TYPE/assimp.a
	fi
}

# executed inside the lib src dir
function clean() {

	if [ "$TYPE" == "vs" ] ; then
		echoWarning "TODO: clean vs"

	elif [ "$TYPE" == "vs" ] ; then
		echoWarning "TODO: clean android"

	else
		make clean
		rm -f CMakeCache.txt
	fi
}
