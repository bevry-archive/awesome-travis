#!/bin/bash
# Release to NPM
# https://github.com/balupton/awesome-travis#release-to-npm

export ORIGINAL_NODE_VERSION
export LTS_NODE_LATEST_VERSION

ORIGINAL_NODE_VERSION="$(node --version)" || exit -1
LTS_NODE_LATEST_VERSION="$(nvm version-remote --lts)" || exit -1
if test "$ORIGINAL_NODE_VERSION" = "$LTS_NODE_LATEST_VERSION"; then
	if test "$TRAVIS_TAG"; then
		echo "logging in..."
		echo -e "$NPM_USERNAME\n$NPM_PASSWORD\n$NPM_EMAIL" | npm login || exit -1
		echo "publishing..."
		npm publish || exit -1
		echo "...released to npm"
	else
		echo "non-tag, no need for release"
	fi
else
	echo "running on non-latest LTS node version, skipping release to npm"
fi