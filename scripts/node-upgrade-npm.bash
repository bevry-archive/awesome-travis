#!/bin/bash

# Prepare
export CURRENT_NPM_VERSION
export ORIGINAL_NPM_VERSION
export LATEST_NPM_VERSION

# Ensure npm is the latest
ORIGINAL_NPM_VERSION="$(npm --version)" || exit -1
LATEST_NPM_VERSION="$(npm view npm version)" || exit -1
if test "$ORIGINAL_NPM_VERSION" != "$LATEST_NPM_VERSION"; then
	echo "running an old npm version $ORIGINAL_NPM_VERSION"

	echo "upgrading npm to $LATEST_NPM_VERSION..."
	npm install npm --global --cache-min=Infinity || exit -1
	CURRENT_NPM_VERSION="$(npm --version)" || exit -1
	echo "...npm upgraded to $CURRENT_NPM_VERSION"
fi
