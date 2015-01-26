#!/bin/sh

# The MIT License (MIT)

# Copyright (c) 2014 Daniel Rosser 

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

echo "----------------------------------"
echo "Merge All For Travis v1.0 (OSX Edition)."
echo "----------------------------------"


#!/bin/sh
here="`dirname \"$0\"`"
echo "cd-ing to $here"
cd "$here" || exit 1

# Function to get an addon
# Param1: to merge from
# Param2: to merge to
DoMerge(){

if [ "$1" == "" ]
then
    echo "----------------------"
    echo "FATAL ERROR! Parameter 1 - 'from branch' No specified!"
    echo "----------------------"
    exit;
fi
if [ "$2" == "" ]
then
    echo "----------------------"
    echo "FATAL ERROR! Parameter 2 - 'to branch' not specified"
    echo "----------------------"
    exit;
fi
echo "========================"
echo "From Branch:    $1"
echo "To Merge to Branch:  $2"

git checkout $2
# merge 1 from to 2
git merge $1 $2


echo "========================"
}


DoMerge "master" "freeimage-ios"
DoMerge "master" "freetype-ios"
DoMerge "master" "openssl-ios"
DoMerge "master" "poco-ios"
DoMerge "master" "tess2-ios"
DoMerge "master" "opencv-ios"
DoMerge "master" "assimp-ios"

DoMerge "master" "freeimage-osx"
DoMerge "master" "freetype-osx"
DoMerge "master" "openssl-osx"
DoMerge "master" "poco-osx"
DoMerge "master" "tess2-osx"
DoMerge "master" "opencv-osx"
DoMerge "master" "assimp-osx"





#===============================================================================
