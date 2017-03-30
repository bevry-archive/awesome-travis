#!/bin/bash

# Ensure dependencies install with a LTS node version
# https://github.com/balupton/awesome-travis#use-lts-node-version-for-preparation
export CURRENT_NODE_VERSION="$(node --version)" || exit -1
export LTS_NODE_VERSIONS="$(nvm ls-remote --lts)" || exit -1
if echo "$LTS_NODE_VERSIONS" | grep "$CURRENT_NODE_VERSION"; then
	echo "running on a LTS node version, completing setup..."
	npm run our:setup || exit -1
	echo "...setup complete with current LTS version"
else
	echo "running on a non-LTS node version, completing setup on a LTS node version..."
	nvm install --lts || exit -1
	export LTS_NODE_INSTALLED_VERSION="$(node --version)" || exit -1
	npm run our:setup || exit -1
	nvm use "$TRAVIS_NODE_VERSION" || exit -1
	echo "...setup complete with LTS"
fi