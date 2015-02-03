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

if [ "$3" == "" ]
    COMMITMSG="Automatic commit"
then
    COMMITMSG="${3}"
fi

echo "========================"
echo "From Branch:    $1"
echo "To Merge to Branch:  $2"

git checkout $2
if [ $? != 0 ];
then
    echo "Problem while checking out $1"
    exit 1
else
    echo "Checkout successful for $1"
fi

if [[ $COMMITMSG == *"$2"* ]]
then
    echo "Pushing this commit live"
    FINALMSG="${COMMITMSG}"
elif [[ $COMMITMSG == *"All"* ]]
then
    echo "All - Pushing this commit live"
    FINALMSG="${COMMITMSG}"
else
    FINALMSG="${COMMITMSG} [skip ci]"
    echo "Not found in commit message, not updating travis"
fi

echo "Commit Message: ${FINALMSG}"

# merge 1 from to 2
git merge --commit -m "${FINALMSG}" --progress $1 $2
if [ $? != 0 ];
then
    echo "Problem while merging $1 into $2"
    exit 1
else
    echo "Merge successful for $1 into $2"
    git checkout master 
fi

echo "------------------"

sleep 2


}

# --------------- Edit here

#MESSAGE="Update All Branches [skip ci]"
MESSAGE="Update cairo-osx freetype-osx freetype-ios"

DoMerge "master" "freeimage-ios" "${MESSAGE}"
DoMerge "master" "freetype-ios" "${MESSAGE}"
DoMerge "master" "openssl-ios" "${MESSAGE}"
DoMerge "master" "poco-ios" "${MESSAGE}"
DoMerge "master" "tess2-ios" "${MESSAGE}"
DoMerge "master" "opencv-ios" "${MESSAGE}"
DoMerge "master" "assimp-ios" "${MESSAGE}"

DoMerge "master" "freeimage-osx" "${MESSAGE}"
DoMerge "master" "freetype-osx" "${MESSAGE}"
DoMerge "master" "openssl-osx" "${MESSAGE}"
DoMerge "master" "poco-osx" "${MESSAGE}"
DoMerge "master" "tess2-osx" "${MESSAGE}"
DoMerge "master" "opencv-osx" "${MESSAGE}"
DoMerge "master" "assimp-osx" "${MESSAGE}"

DoMerge "master" "glfw-osx" "${MESSAGE}"
DoMerge "master" "glew-osx" "${MESSAGE}"


# --------------- <

echo "========================"
echo "Finished Sucessfully. Pushing to remote"
git push 




#===============================================================================
