apothecary-den
==============

Apothecary Formula Automated Testing (Travis has volunteered to drink our potions!)

What is Apothecary? 
----------
It is a Alchemy lab that mixes formulas and potions to build and update the C/C++ lib dependencies for [openframeworks/openFrameworks](https://github.com/openframeworks/openFrameworks)

More info: [openFrameworks/scripts/apothecary](https://github.com/openframeworks/openFrameworks/tree/master/scripts/apothecary)


# Build Status:

| Lib                             | osx |  ios | 
|---------------------------------|-----|-------|
| FreeImage                       |[![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=freeimage-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=freeimage-osx) | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=freeimage-ios)](https://travis-ci.org/danoli3/apothecary-den?branch=freeimage-ios) |
| FreeType                        |[![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=freetype-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=freetype-osx) | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=freetype-ios)](https://travis-ci.org/danoli3/apothecary-den?branch=freetype-ios) | 
| tess2                           | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=tess2-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=tess2-osx) | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=tess2-ios)](https://travis-ci.org/danoli3/apothecary-den?branch=tess2-ios)| 
| poco                            |[![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=poco-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=poco-osx) | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=poco-ios)](https://travis-ci.org/danoli3/apothecary-den?branch=poco-ios) | 
| openssl                         | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=openssl-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=openssl-osx) | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=openssl-ios)](https://travis-ci.org/danoli3/apothecary-den?branch=openssl-ios)| 
| ofxAssimpModelLoader -> assimp  |[![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=assimp-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=assimp-osx) | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=assimp-ios)](https://travis-ci.org/danoli3/apothecary-den?branch=assimp-ios) |
| ofxOpenCV -> opencv             | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=opencv-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=opencv-osx) | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=opencv-ios)](https://travis-ci.org/danoli3/apothecary-den?branch=opencv-ios) |
| glew                            | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=glew-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=glew-osx)| N/A | 
| glfw                            | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=glfw-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=glfw-osx) | N/A |
| cairo                          | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=cairo-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=cairo-osx) |  N/A  |
| portaudio                       | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=fmod-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=fmod-osx) |  N/A |
| fmodex                            | ✓?  | N/A  | 
| rtAudio                         | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=rtaudio-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=rtaudio-osx)  |  N/A | 
| Boost 1.58.0 FileSystem                       |[![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=boost-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=boost-osx) | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=boost-ios)](https://travis-ci.org/danoli3/apothecary-den?branch=boost-ios) |
| URI                       |[![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=uri-osx)](https://travis-ci.org/danoli3/apothecary-den?branch=uri-osx) | [![Build Status](https://travis-ci.org/danoli3/apothecary-den.svg?branch=uri-ios)](https://travis-ci.org/danoli3/apothecary-den?branch=uri-ios) |

----------------------------------

** Build Error sometimes means travis is timing out over 10 minutes (which means it could be just building something for more than 10 minutes with no response.). The log output silencing was due to getting over 100,000 lines for some libraries, which was also a Build Error
