#!/bin/bash

# Use the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version) to login with npm and run `npm publish`.
#
#
# Installation:
#
# after_success:
#   - eval "$(curl -s https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-publish.bash)"
#
#
# Configuration:
#
# Specficy a specific node version (rather than the LTS version)
# travis env set DESIRED_NODE_VERSION "7" --public
#
# Specify your npm token (you can use this instead of the npm username+password+email)
# travis env set NPM_AUTHTOKEN "$NPM_AUTHTOKEN"
#
# Specify your npm username:
# travis env set NPM_USERNAME "$NPM_USERNAME" --public
#
# Specify your npm password
# travis env set NPM_PASSWORD "$NPM_PASSWORD"
#
# Specify your npm email
# travis env set NPM_EMAIL "$NPM_EMAIL"


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
		if test "$NPM_AUTHTOKEN"; then
			echo "creating npmrc with auth token..."
			echo "//registry.npmjs.org/:_authToken=$NPM_AUTHTOKEN" > "$HOME/.npmrc"
		elif test "$NPM_USERNAME"; then
			echo "installing automated npm login command..."
			npm install -g npm-login-cmd || exit -1
			echo "logging in..."
			env NPM_USER="$NPM_USERNAME" NPM_PASS="$NPM_PASSWORD" npm-login-cmd || exit -1
		else
			echo "your must provide NPM_AUTHTOKEN or a (NPM_USERNAME, NPM_PASSWORD, NPM_EMAIL) combination"
			exit -1
		fi
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
