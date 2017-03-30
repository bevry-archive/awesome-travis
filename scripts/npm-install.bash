#!/bin/bash
# Ensure dependencies install with a LTS node version
# https://github.com/balupton/awesome-travis#use-lts-node-version-for-preparation

export ORIGINAL_NODE_VERSION
export LTS_NODE_VERSIONS
export LTS_NODE_INSTALLED_VERSION

ORIGINAL_NODE_VERSION="$(node --version)" || exit -1
LTS_NODE_VERSIONS="$(nvm ls-remote --lts)" || exit -1
if echo "$LTS_NODE_VERSIONS" | grep "$ORIGINAL_NODE_VERSION"; then
	echo "running on the LTS node version $ORIGINAL_NODE_VERSION"

	echo "completing setup with $ORIGINAL_NODE_VERSION..."
	npm run our:setup || exit -1
	echo "...setup complete with $ORIGINAL_NODE_VERSION"
else
	echo "running on the non-LTS node version $ORIGINAL_NODE_VERSION"

	echo "installing a LTS version..."
	nvm install --lts || exit -1
	LTS_NODE_INSTALLED_VERSION="$(node --version)" || exit -1
	echo "...installed the LTS version $LTS_NODE_INSTALLED_VERSION"

	echo "completing setup with $LTS_NODE_INSTALLED_VERSION..."
	npm run our:setup || exit -1
	echo "...setup complete with $LTS_NODE_INSTALLED_VERSION"

	echo "switching back to $ORIGINAL_NODE_VERSION"
	nvm use "$ORIGINAL_NODE_VERSION" || exit -1
	echo "...switched back to $ORIGINAL_NODE_VERSION"
fi