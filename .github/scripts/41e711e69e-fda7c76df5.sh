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

true

echo '==================================> BEFORE_SCRIPT'

. $GITHUB_WORKSPACE/.github/scripts/before-script.sh

echo '==================================> SCRIPT'

cd test/cmake_subdir_test && mkdir __build__ && cd __build__
cmake ..
cmake --build .
cmake --build . --target check

echo '==================================> AFTER_SUCCESS'

. $GITHUB_WORKSPACE/.github/scripts/after-success.sh
