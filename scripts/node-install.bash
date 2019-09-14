#!/bin/bash
set -ueE -o pipefail

# Use the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version) to install dependencies using `SETUP_COMMAND` (defaults to `npm install`).

# SCRIPT
#
# install:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-install.bash)"

# CUSTOM ENVIRONMENT VARIABLES
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
	DESIRED_NODE_VERSION="$(set +u && nvm version-remote --lts && set -u)"
else
	DESIRED_NODE_VERSION="$(set +u && nvm version-remote "$DESIRED_NODE_VERSION" && set -u)"
fi
if test -z "${SETUP_COMMAND-}"; then
	SETUP_COMMAND="npm run our:setup"
fi

# Set Local Environment Variables
CURRENT_NODE_VERSION="$(node --version)"

# Run
if test "$CURRENT_NODE_VERSION" = "$DESIRED_NODE_VERSION"; then
	echo "running on node version $CURRENT_NODE_VERSION which IS the desired $DESIRED_NODE_VERSION"

	echo "completing setup with $CURRENT_NODE_VERSION..."
	eval "$SETUP_COMMAND"
	echo "...setup complete with $CURRENT_NODE_VERSION"
else
	echo "running on node version $CURRENT_NODE_VERSION which IS NOT the desired $DESIRED_NODE_VERSION"

	echo "installing the desired version..."
	set +u && nvm install "$DESIRED_NODE_VERSION" && set -u
	echo "...installed the desired $DESIRED_NODE_VERSION"

	echo "completing setup with $DESIRED_NODE_VERSION..."
	eval "$SETUP_COMMAND"
	echo "...setup complete with $DESIRED_NODE_VERSION"

	echo "switching back to $CURRENT_NODE_VERSION"
	set +u && nvm use "$CURRENT_NODE_VERSION" && set -u
	echo "...switched back to $CURRENT_NODE_VERSION"
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u
