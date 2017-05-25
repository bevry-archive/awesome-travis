#!/bin/bash

# Ensure that the npm version is the latest.
#
#
# Installation:
#
# after_success:
#   - eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/node-upgrade-npm.bash)"


# Local Environment Variables:
export ORIGINAL_NPM_VERSION
export LATEST_NPM_VERSION
ORIGINAL_NPM_VERSION="$(npm --version)" || exit -1
LATEST_NPM_VERSION="$(npm view npm version)" || exit -1

# Ensure npm is the latest
if test "$ORIGINAL_NPM_VERSION" != "$LATEST_NPM_VERSION"; then
	echo "running an old npm version $ORIGINAL_NPM_VERSION"

	echo "upgrading npm to $LATEST_NPM_VERSION..."
	npm update npm --global --cache-min=Infinity || exit -1
	echo "...npm upgraded to $CURRENT_NPM_VERSION"
fi
