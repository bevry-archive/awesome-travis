#!/bin/bash
set -ueE -o pipefail

# Use the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version) to install dependencies using `SETUP_COMMAND` (defaults to `npm install`).

# TRAVIS SCRIPT
#
# install:
#   - eval "$(curl -s https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-install.bash)"

# TRAVIS ENVIRONMENT VARIABLES
#
# DESIRED_NODE_VERSION
# To specify a specific node version (rather tha the LTS version):
# travis env set DESIRED_NODE_VERSION "7" --public
#
# SETUP_COMMAND
# To setup the project with a custom command, do so with:
# travis env set SETUP_COMMAND "npm run our:setup" --public

# Default User Environment Variables
if test -z "${DESIRED_NODE_VERSION-}"; then
	DESIRED_NODE_VERSION="$(nvm version-remote --lts)"
else
	DESIRED_NODE_VERSION="$(nvm version-remote "$DESIRED_NODE_VERSION")"
fi
if test -z "${SETUP_COMMAND-}"; then
	SETUP_COMMAND="npm run our:setup"
fi

# Set Local Environment Variables
ORIGINAL_NODE_VERSION="$(node --version)"

# Run
if test "$ORIGINAL_NODE_VERSION" = "$DESIRED_NODE_VERSION"; then
	echo "running on node version $ORIGINAL_NODE_VERSION which IS the desired $DESIRED_NODE_VERSION"

	echo "completing setup with $ORIGINAL_NODE_VERSION..."
	eval "$SETUP_COMMAND"
	echo "...setup complete with $ORIGINAL_NODE_VERSION"
else
	echo "running on node version $CURRENT_NODE_VERSION which IS NOT the desired $DESIRED_NODE_VERSION"

	echo "installing the desired version..."
	nvm install "$DESIRED_NODE_VERSION"
	echo "...installed the desired $DESIRED_NODE_VERSION"

	echo "completing setup with $DESIRED_NODE_VERSION..."
	eval "$SETUP_COMMAND"
	echo "...setup complete with $DESIRED_NODE_VERSION"

	echo "switching back to $ORIGINAL_NODE_VERSION"
	nvm use "$ORIGINAL_NODE_VERSION"
	echo "...switched back to $ORIGINAL_NODE_VERSION"
fi
