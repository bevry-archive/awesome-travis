#!/bin/bash

# Ensure compilation and verification occur on a LTS node version
# https://github.com/balupton/awesome-travis#use-lts-node-version-for-preparation

# ./npm-install.bash provides:
# LTS_NODE_INSTALLED_VERSION
# CURRENT_NODE_VERSION
if test "$LTS_NODE_INSTALLED_VERSION"; then
	echo "running on the non-LTS node version $CURRENT_NODE_VERSION"

	echo "swapping to $LTS_NODE_INSTALLED_VERSION..."
	nvm use "$LTS_NODE_INSTALLED_VERSION" || exit -1
	echo "...swapped to $LTS_NODE_INSTALLED_VERSION"

	echo "compiling with $LTS_NODE_INSTALLED_VERSION..."
	npm run our:compile || exit -1
	echo "...compiled with $LTS_NODE_INSTALLED_VERSION"

	echo "swapping back to $CURRENT_NODE_VERSION"
	nvm use "$CURRENT_NODE_VERSION" || exit -1
	echo "...swapped back to $CURRENT_NODE_VERSION"
else
	echo "running on the LTS node version $CURRENT_NODE_VERSION"

	echo "compiling and verifying with $CURRENT_NODE_VERSION..."
	npm run our:compile && npm run our:verify || exit -1
	echo "...compiled and verified with $CURRENT_NODE_VERSION"
fi