#!/bin/bash

# Ensure compilation and linting occur on a LTS node version
# https://github.com/balupton/awesome-travis#use-lts-node-version-for-preparation
if test "$LTS_NODE_INSTALLED_VERSION"; then
	echo "running on a non-LTS node version, compiling with LTS, skipping linting..."
	nvm use "$LTS_NODE_INSTALLED_VERSION" || exit -1
	npm run our:compile || exit -1
	nvm use "$TRAVIS_NODE_VERSION" || exit -1
	echo "...compiled"
else
	echo "running on a LTS node version, compiling and linting..."
	npm run our:compile && npm run our:verify || exit -1
	echo "...compiled and linted"
fi