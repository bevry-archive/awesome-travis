#!/bin/bash

# Installs the `DESIRED_NODE_VERSION` if set, otherwise install latest LTS node version.
#
# Optional Configuration Commands:
# travis env set DESIRED_NODE_VERSION "7"

# User Environment Variables:
export DESIRED_NODE_VERSION
if test -z "$DESIRED_NODE_VERSION"; then
	DESIRED_NODE_VERSION="$(nvm version-remote --lts)" || exit -1
else
	DESIRED_NODE_VERSION="$(nvm version-remote "$DESIRED_NODE_VERSION")" || exit -1
fi

# Local Environment Variables:
export ORIGINAL_NODE_VERSION
ORIGINAL_NODE_VERSION="$(node --version)" || exit -1

# upgrade npm on original node version
# eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/node-upgrade-npm.bash)"

# Run
if test "$ORIGINAL_NODE_VERSION" = "$DESIRED_NODE_VERSION"; then
	echo "running on node version $ORIGINAL_NODE_VERSION which IS the desired $DESIRED_NODE_VERSION"

	echo "completing setup with $ORIGINAL_NODE_VERSION..."
	npm run our:setup || exit -1
	echo "...setup complete with $ORIGINAL_NODE_VERSION"
else
	echo "running on node version $CURRENT_NODE_VERSION which IS NOT the desired $DESIRED_NODE_VERSION"

	echo "installing the desired version..."
	nvm install "$DESIRED_NODE_VERSION" || exit -1
	echo "...installed the desired $DESIRED_NODE_VERSION"

	# upgrade npm on original node version
	# eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/node-upgrade-npm.bash)"

	echo "completing setup with $DESIRED_NODE_VERSION..."
	npm run our:setup || exit -1
	echo "...setup complete with $DESIRED_NODE_VERSION"

	echo "switching back to $ORIGINAL_NODE_VERSION"
	nvm use "$ORIGINAL_NODE_VERSION" || exit -1
	echo "...switched back to $ORIGINAL_NODE_VERSION"
fi
