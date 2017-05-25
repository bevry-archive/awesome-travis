#!/bin/bash

# Use the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version) to login with npm and run `npm publish`.
#
#
# Installation:
#
# after_success:
#   - eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/node-publish.bash)"
#
#
# Configuration:
#
# To specify a specific node version (rather tha the LTS version)
# travis env set DESIRED_NODE_VERSION "7"


# External Environment Variables:
export DESIRED_NODE_VERSION
if test -z "$DESIRED_NODE_VERSION"; then
	DESIRED_NODE_VERSION="$(nvm version-remote --lts)" || exit -1
else
	DESIRED_NODE_VERSION="$(nvm version-remote "$DESIRED_NODE_VERSION")" || exit -1
fi

# Local Environment Variables:
export CURRENT_NODE_VERSION
CURRENT_NODE_VERSION="$(node --version)" || exit -1

# Run
if test "$CURRENT_NODE_VERSION" = "$DESIRED_NODE_VERSION"; then
	echo "running on node version $CURRENT_NODE_VERSION which IS the desired $DESIRED_NODE_VERSION"
	if test "$TRAVIS_TAG"; then
		echo "releasing to npm..."
		echo "logging in..."
		echo -e "$NPM_USERNAME\n$NPM_PASSWORD\n$NPM_EMAIL" | npm login || exit -1
		echo "publishing..."
		npm publish || exit -1
		echo "...released to npm"
	else
		echo "non-tag, no need for release"
	fi
else
	echo "running on node version $CURRENT_NODE_VERSION which IS NOT the desired $DESIRED_NODE_VERSION"
	echo "skipping release to npm"
fi
