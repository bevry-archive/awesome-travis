#!/bin/bash
set -ueE -o pipefail

# Because the latest npm version that node 0.6 and 0.9 support, doesn't support scoped modules, so it uses node 0.8 to install npm packages and then switches back.

# SCRIPT
#
# install:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-npm-install.bash)"

# TRAVIS ENVIRONMENT VARIABLES
#
# TRAVIS_NODE_VERSION

if [ "${TRAVIS_NODE_VERSION}" = "0.6" ] || [ "${TRAVIS_NODE_VERSION}" = "0.9" ]; then
	set +u && nvm install --latest-npm 0.8 && npm install && nvm use "${TRAVIS_NODE_VERSION}" && set -u
else
	npm install
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u
