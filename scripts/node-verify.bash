#!/bin/bash
set -ueE -o pipefail

# If our current node version is the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version)
# then compile and lint our project with: `npm run our:compile && npm run our:verify`
# otherwise just compile our project with: `npm run our:compile`

# SCRIPT
#
# before_script:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-verify.bash)"

# CUSTOM ENVIRONMENT VARIABLES
#
# DESIRED_NODE_VERSION
# To specify a specific node version (rather than the LTS version)
# travis env set DESIRED_NODE_VERSION "7" --public
#
# COMPILE_COMMAND
# To compile the project with a custom command, do so with:
# travis env set COMPILE_COMMAND "npm run our:compile" --public
#
# VERIFY_COMMAND
# To verify the project with a custom command, do so with:
# travis env set VERIFY_COMMAND "npm run our:verify" --public

# Default User Environment Variables
if test -z "${DESIRED_NODE_VERSION-}"; then
	DESIRED_NODE_VERSION="$(set +u && nvm version-remote --lts && set -u)"
else
	DESIRED_NODE_VERSION="$(set +u && nvm version-remote "$DESIRED_NODE_VERSION" && set -u)"
fi
if test -z "${COMPILE_COMMAND-}"; then
	COMPILE_COMMAND="npm run our:compile"
fi
if test -z "${VERIFY_COMMAND-}"; then
	VERIFY_COMMAND="npm run our:verify"
fi

# Set Local Environment Variables
CURRENT_NODE_VERSION="$(node --version)"

# Run
if test "$CURRENT_NODE_VERSION" = "$DESIRED_NODE_VERSION"; then
	echo "running on node version $CURRENT_NODE_VERSION which IS the desired $DESIRED_NODE_VERSION"

	echo "compiling and verifying with $CURRENT_NODE_VERSION..."
	(eval "$COMPILE_COMMAND" && eval "$VERIFY_COMMAND")
	echo "...compiled and verified with $CURRENT_NODE_VERSION"
else
	echo "running on node version $CURRENT_NODE_VERSION which IS NOT the desired $DESIRED_NODE_VERSION"

	echo "swapping to $DESIRED_NODE_VERSION..."
	set +u && nvm install "$DESIRED_NODE_VERSION" && set -u
	echo "...swapped to $DESIRED_NODE_VERSION"

	echo "compiling with $DESIRED_NODE_VERSION..."
	eval "$COMPILE_COMMAND"
	echo "...compiled with $DESIRED_NODE_VERSION"

	echo "swapping back to $CURRENT_NODE_VERSION"
	set +u && nvm use "$CURRENT_NODE_VERSION" && set -u
	echo "...swapped back to $CURRENT_NODE_VERSION"
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u