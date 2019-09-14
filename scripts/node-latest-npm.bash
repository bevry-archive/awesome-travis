#!/bin/bash
set -ueE -o pipefail

# Installs the latest npm version, using npm's `update` command.

# SCRIPT
#
# install:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-latest-npm.bash)"

# Set Local Environment Variables
ORIGINAL_NPM_VERSION="$(npm --version)"
LATEST_NPM_VERSION="$(npm view npm version)"

# Ensure npm is the latest
if test "$ORIGINAL_NPM_VERSION" != "$LATEST_NPM_VERSION"; then
	echo "running an old npm version $ORIGINAL_NPM_VERSION"
	echo "upgrading npm to $LATEST_NPM_VERSION..."
	npm update npm --global --cache-min=Infinity
	echo "...npm upgraded to $CURRENT_NPM_VERSION"
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u