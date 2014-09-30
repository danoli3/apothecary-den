#! /bin/bash
#
# Free Image
# cross platform image io
# http://freeimage.sourceforge.net
#
# Makefile build system, 
# some Makefiles are out of date so patching/modification may be required

FORMULA_TYPES=( "osx" "vs" "win_cb" "ios" "android" )

# define the version
VER=3160 # 3.16.0

# tools for git use
GIT_URL=
GIT_TAG=

# download the source code and unpack it into LIB_NAME
function download() {
	if [ "$TYPE" == "vs" -o "$TYPE" == "win_cb" ] ; then
		# For win32, we simply download the pre-compiled binaries.
		curl -LO http://downloads.sourceforge.net/freeimage/FreeImage"$VER"Win32.zip
		unzip -qo FreeImage"$VER"Win32.zip
		rm FreeImage"$VER"Win32.zip
	else
		curl -LO http://downloads.sourceforge.net/freeimage/FreeImage"$VER".zip
		unzip -qo FreeImage"$VER".zip
		rm FreeImage"$VER".zip
	fi
}

# prepare the build environment, executed inside the lib src dir
function prepare() {
	
	if [ "$TYPE" == "osx" ] ; then

		# patch outdated Makefile.osx provided with FreeImage, check if patch was applied first
		if patch -p0 -u -N --dry-run --silent < $FORMULA_DIR/Makefile.osx.patch 2>/dev/null ; then
			patch -p0 -u < $FORMULA_DIR/Makefile.osx.patch
		fi

		# set SDK using apothecary settings
		sed -i tmp "s|MACOSX_SDK =.*|MACOSX_SDK = $OSX_SDK_VER|" Makefile.osx
		sed -i tmp "s|MACOSX_MIN_SDK =.*|MACOSX_MIN_SDK = $OSX_MIN_SDK_VER|" Makefile.osx

	elif [ "$TYPE" == "ios" ] ; then

		mkdir -p Dist/$TYPE
		mkdir -p builddir/$TYPE

		# copy across new Makefile for iOS.
		cp -v $FORMULA_DIR/Makefile.ios Makefile.ios
	fi
}

# executed inside the lib src dir
function build() {
	
	if [ "$TYPE" == "osx" ] ; then
		make -f Makefile.osx

		strip -x Dist/libfreeimage.a

	elif [ "$TYPE" == "ios" ] ; then

		# Notes: 
        # --- for 3.1+ Must use "-DNO_LCMS -D__ANSI__ -DDISABLE_PERF_MEASUREMENT" to compile LibJXR
        # --- arm64 has lots of hotfixes using sed inline here.
		export TOOLCHAIN=$XCODE_DEV_ROOT/Toolchains/XcodeDefault.xctoolchain
		export TARGET_IOS
        
        local IOS_ARCHS="i386 x86_64 armv7 armv7s arm64"
        #local IOS_ARCHS="arm64" # for future arm64
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

        #cp -v Makefile.srcs Makefile.srcs.orig
        #mv -v Source/LibJXR/image/sys/image.c Source/LibJXR/image/sys/imagejxr.c

        #sed -i tmp "s|Source/LibJXR/./image/sys/image.c|Source/LibJXR/./image/sys/imagejxr.c|" Makefile.srcs


        # loop through architectures! yay for loops!
        for IOS_ARCH in ${IOS_ARCHS}
        do

        	unset ARCH IOS_DEVROOT IOS_SDKROOT IOS_CC TARGET_NAME HEADER
            unset CC CPP CXX CXXCPP CFLAGS CXXFLAGS LDFLAGS LD AR AS NM RANLIB LIBTOOL 
            unset EXTRA_PLATFORM_CFLAGS EXTRA_PLATFORM_LDFLAGS IOS_PLATFORM NO_LCMS

            export ARCH=$IOS_ARCH


            
            local EXTRA_PLATFORM_CFLAGS="" # will add -fvisibility=hidden $(INCLUDE) to makefile
			export EXTRA_PLATFORM_LDFLAGS=""
			#export ALL_IOS_ARCH="-arch armv7 -arch armv7s -arch arm64"
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

			#export TARGET_NAME="build/$TYPE/$IOS_ARCH/libfreeimage.a"
			export TARGET_NAME="libfreeimage-$IOS_ARCH.a"
			export HEADER="Source/FreeImage.h"

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

		    	# Manually Fix major issues with arm64 for iOS from some source libraries.
		    #	cp -v Source/ZLib/gzguts.h Source/ZLib/gzguts.h.orig
		    	#define LSEEK errors fixed by definig unistd for ZLib
		   # 	sed -i temp '20i\
					#include <unistd.h>' Source/ZLib/gzguts.h

			#	cp -v Source/LibJXR/image/decode/segdec.c Source/LibJXR/image/decode/segdec.c.orig
				
		    	#sed -e 's/#if defined(_M_IA64) || defined(_ARM_)/#if defined(_M_IA64) || defined(_ARM_) || defined(__ARMEL__) || defined(_M_ARM) || defined(__arm__) || defined(__arm64__)/g' Source/LibJXR/image/decode/segdec.c > Source/LibJXR/image/decode/segdec.c

		    	#cp -v Source/LibJXR/image/sys/xplatform_image.h Source/LibJXR/image/sys/xplatform_image.h.orig
		    	#sed -e 's/#if defined(_ARM_) || defined(UNDER_CE)/#if defined(_ARM_) || defined(UNDER_CE) || defined(__ARMEL__) || defined(_M_ARM) || defined(__arm__) || defined(__arm64__)/g' Source/LibJXR/image/sys/xplatform_image.h> Source/LibJXR/image/decode/segdec.c

		    #	cp -v Source/LibJXR/jxrgluelib/JXRGlueJxr.c Source/LibJXR/jxrgluelib/JXRGlueJxr.c.orig

		    #	sed -i temp '31i\
					#include <wchar.h>' Source/LibJXR/./jxrgluelib/JXRGlueJxr.c

		   # fi
		  	export EXTRA_PLATFORM_CFLAGS="$EXTRA_PLATFORM_CFLAGS" # will add -fvisibility=hidden $(INCLUDE) to makefile
			export EXTRA_PLATFORM_LDFLAGS="$EXTRA_PLATFORM_LDFLAGS -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -Wl,-dead_strip -I${CROSS_TOP}/SDKs/${CROSS_SDK}/usr/include/ $MIN_TYPE$MIN_IOS_VERSION "
			
		   	EXTRA_LINK_FLAGS="-stdlib=libc++ -Os -fPIC"
			EXTRA_FLAGS="$EXTRA_LINK_FLAGS -pipe -fvisibility-inlines-hidden -Wno-ctor-dtor-privacy -Wc++11-narrowing -Wall -Wmissing-prototypes $EXTRA_PLATFORM_CFLAGS -ffast-math -fno-strict-aliasing -fmessage-length=0 -fexceptions -D__ANSI__ -DDISABLE_PERF_MEASUREMENT -fvisibility=hidden $MIN_TYPE$MIN_IOS_VERSION -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -I${CROSS_TOP}/SDKs/${CROSS_SDK}/usr/include/"

		    export CC="$CC -std=c11 $EXTRA_LINK_FLAGS"
			export CFLAGS="-arch $IOS_ARCH $EXTRA_FLAGS"
			export CXXFLAGS="-fvisibility-inlines-hidden $EXTRA_FLAGS -std=c++11"
			export LDFLAGS="-arch $IOS_ARCH $EXTRA_PLATFORM_LDFLAGS $EXTRA_LINK_FLAGS $MIN_TYPE$MIN_IOS_VERSION"
			export LDFLAGS_PHONE=$LDFLAGS

			mkdir -p "$CURRENTPATH/builddir/$TYPE/$IOS_ARCH"
			LOG="$CURRENTPATH/builddir/$TYPE/$IOS_ARCH/build-freeimage-${VER}-$IOS_ARCH.log"
			echo "-----------------"
			echo "Building FreeImage-${VER} for ${PLATFORM} ${SDKVERSION} ${IOS_ARCH} : iOS Minimum=$MIN_IOS_VERSION"
			set +e

			echo "Running make for ${IOS_ARCH}"
			echo "Please stand by..."

			
			# run makefile
			make -f Makefile.ios >> "${LOG}" 2>&1
			if [ $? != 0 ];
		    then 
		    	echo "Problem while make - Please check ${LOG}"
		    	exit 1
		    else
		    	echo "Make Successful for ${IOS_ARCH}"
		    fi

			echo "Running make clean"
			echo "Please stand by..."
			make clean >> "${LOG}" 2>&1

			if [ $? != 0 ];
		    then 
		    	echo "Problem while make clean - Please check ${LOG}"
		    	exit 1
		    else
		    	echo "Make clean Successful for ${IOS_ARCH}"
		    fi
      
            unset ARCH IOS_DEVROOT IOS_SDKROOT IOS_CC TARGET_NAME HEADER
            unset CC CPP CXX CXXCPP CFLAGS CXXFLAGS LDFLAGS LD AR AS NM RANLIB LIBTOOL 
            unset EXTRA_PLATFORM_CFLAGS EXTRA_PLATFORM_LDFLAGS IOS_PLATFORM NO_LCMS

            #if [ "$IOS_ARCH" == "arm64" ] ; then
		    
		    	# reset back to originals
		    	#cp -v Source/ZLib/gzguts.h.orig Source/ZLib/gzguts.h
				#cp -v Source/LibJXR/image/decode/segdec.c.orig Source/LibJXR/image/decode/segdec.c
				#cp -v Source/LibJXR/image/sys/xplatform_image.h.orig Source/LibJXR/image/sys/xplatform_image.h
				#cp -v Source/LibJXR/jxrgluelib/JXRGlueJxr.c.orig Source/LibJXR/jxrgluelib/JXRGlueJxr.c

		    #fi
     	

     		echo "Completed Build for $IOS_ARCH of FreeType"

     		mv -v libfreeimage-$IOS_ARCH.a Dist/$TYPE/libfreeimage-$IOS_ARCH.a

     		cp Source/FreeImage.h Dist

		done

		echo "Completed Build for $TYPE"

		#cp -v Makefile.srcs.orig Makefile.srcs
        #mv -v Source/LibJXR/image/sys/imagejxr.c Source/LibJXR/image/sys/image.c

        echo "-----------------"
		echo `pwd`
		echo "Finished for all architectures."
		mkdir -p "$CURRENTPATH/builddir/$TYPE/$IOS_ARCH"
		LOG="$CURRENTPATH/builddir/$TYPE/build-freeimage-${VER}-lipo.log"


		cd Dist/$TYPE/
		# link into universal lib
		echo "Running lipo to create fat lib"
		echo "Please stand by..."
		lipo -create libfreeimage-armv7.a \
					libfreeimage-armv7s.a \
					libfreeimage-arm64.a \
					libfreeimage-i386.a \
					libfreeimage-x86_64.a \
					-output freeimage.a >> "${LOG}" 2>&1


		if [ $? != 0 ];
		then 
		    echo "Problem while creating fat lib with lipo - Please check ${LOG}"
		    exit 1
		else
		   	echo "Lipo Successful."
		fi

		lipo -info freeimage.a
		echo "--------------------"
		echo "Stripping any lingering symbols"

		SLOG="$CURRENTPATH/lib/$TYPE/tess2-stripping.log"


		# validate all stripped debug:
		strip -x freeimage.a  >> "${SLOG}" 2>&1
		if [ $? != 0 ];
		then 
		    echo "Problem while stripping lib - Please check ${SLOG}"
		    exit 1
		else
		    echo "Strip Successful for ${SLOG}"
		fi
		cd ../../

		echo "--------------------"
		echo "Build Successful for FreeImage $TYPE $VER"

		# include copied in the makefile to libs/$TYPE/include
		unset TARGET_IOS
		unset TOOLCHAIN

	elif [ "$TYPE" == "android" ] ; then
		echoWarning "TODO: android build"
	fi
}

# executed inside the lib src dir, first arg $1 is the dest libs dir root
function copy() {
	
	# headers
	mkdir -p $1/include
	
	cp -v Dist/*.h $1/include
	

	# lib
	if [ "$TYPE" == "osx" ] ; then
		mkdir -p $1/lib/$TYPE
		cp -v Dist/libfreeimage.a $1/lib/$TYPE/freeimage.a
	elif [ "$TYPE" == "vs" -o "$TYPE" == "win_cb" ] ; then
		mkdir -p $1/lib/$TYPE
		cp -v Dist/FreeImage.lib $1/lib/$TYPE/FreeImage.lib
		cp -v Dist/FreeImage.dll $1/../../export/$TYPE/FreeImage.dll
	elif [ "$TYPE" == "ios" ] ; then
		mkdir -p $1/lib/$TYPE
		cp -v Dist/$TYPE/freeimage.a $1/lib/$TYPE/freeimage.a

	elif [ "$TYPE" == "android" ] ; then
		echoWarning "TODO: copy android lib"
	fi	
}

# executed inside the lib src dir
function clean() {
	
	if [ "$TYPE" == "android" ] ; then
		echoWarning "TODO: clean android"
	elif [ "$TYPE" == "ios" ] ; then
		# clean up compiled libraries
		
		make clean
		rm -rf Dist
		rm -f *.a *.lib
		rm -f builddir/$TYPE
		rm -f builddir
		rm -f lib		
	else
		make clean
		# run dedicated clean script
		clean.sh
	fi

}
