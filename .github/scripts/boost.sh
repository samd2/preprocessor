#!/bin/bash

# Copyright 2020 Rene Rivera, Sam Darwin
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.txt or copy at http://boost.org/LICENSE_1_0.txt)

set -ex
export TRAVIS_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=${TRAVIS_BRANCH:-$(echo $GITHUB_REF | awk 'BEGIN { FS = "/" } ; { print $3 }')}
export VCS_COMMIT_ID=$GITHUB_SHA
export GIT_COMMIT=$GITHUB_SHA
export REPO_NAME=$(basename $GITHUB_REPOSITORY)
export PATH=~/.local/bin:/usr/local/bin:$PATH

echo '==================================> BEFORE_INSTALL'

. .github/scripts/before-install.sh

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
cd ..
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule update --init tools/boostdep
cp -r $TRAVIS_BUILD_DIR/* libs/preprocessor
python tools/boostdep/depinst/depinst.py preprocessor
./bootstrap.sh
./b2 headers

echo '==================================> BEFORE_SCRIPT'

. $GITHUB_WORKSPACE/.github/scripts/before-script.sh

echo '==================================> SCRIPT'

echo "using $TOOLSET : : $COMPILER ;" > ~/user-config.jam
./b2 libs/preprocessor/test -j 3 toolset=$TOOLSET cxxstd=$CXXSTD $ADDRMD

echo '==================================> AFTER_SUCCESS'

. $GITHUB_WORKSPACE/.github/scripts/after-success.sh
