#!/bin/bash
set -ueE -o pipefail

# Use the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version) to login with npm and run `npm publish`.

# TRAVIS SCRIPT
#
# after_success:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-publish.bash)"

# TRAVIS ENVIRONMENT VARIABLES
#
# DESIRED_NODE_VERSION
# Specficy a specific node version (rather than the LTS version)
# travis env set DESIRED_NODE_VERSION "7" --public
#
# NPM_AUTHTOKEN
# Specify your npm token (you can use this instead of the npm username+password+email)
# travis env set NPM_AUTHTOKEN "$NPM_AUTHTOKEN"
#
# NPM_USERNAME
# Specify your npm username:
# travis env set NPM_USERNAME "$NPM_USERNAME" --public
#
# NPM_PASSWORD
# Specify your npm password
# travis env set NPM_PASSWORD "$NPM_PASSWORD"
#
# NPM_EMAIL
# Specify your npm email
# travis env set NPM_EMAIL "$NPM_EMAIL"
#
# NPM_VERSION_BUMP
# Specify whether or not to bump the npm version
# travis env set NPM_VERSION_BUMP "patch"

# EXTERNAL ENVIRONMENT VARIABLES
#
# TRAVIS_TAG
# TRAVIS_PULL_REQUEST

# Default User Environment Variables
if test -z "${DESIRED_NODE_VERSION-}"; then
	DESIRED_NODE_VERSION="$(set +u && nvm version-remote --lts && set -u)"
else
	DESIRED_NODE_VERSION="$(set +u && nvm version-remote "$DESIRED_NODE_VERSION" && set -u)"
fi

# Set Local Environment Variables
CURRENT_NODE_VERSION="$(node --version)"

# Run
if test "$TRAVIS_PULL_REQUEST" = "false";
	if "$CURRENT_NODE_VERSION" = "$DESIRED_NODE_VERSION"; then
		echo "running on node version $CURRENT_NODE_VERSION which IS the desired $DESIRED_NODE_VERSION"
		if test -n "${NPM_VERSION_BUMP-}" -o -n "${TRAVIS_TAG-}"; then
			echo "releasing to npm..."
			if test -n "${NPM_AUTHTOKEN-}"; then
				echo "creating npmrc with auth token..."
				echo "//registry.npmjs.org/:_authToken=$NPM_AUTHTOKEN" > "$HOME/.npmrc"
			elif test -n "${NPM_USERNAME-}" -a -n "${NPM_PASSWORD-}"; then
				echo "installing automated npm login command..."
				npm install -g npm-login-cmd
				echo "logging in..."
				env NPM_USER="$NPM_USERNAME" NPM_PASS="$NPM_PASSWORD" npm-login-cmd
			else
				echo "your must provide NPM_AUTHTOKEN or a (NPM_USERNAME, NPM_PASSWORD, NPM_EMAIL) combination"
				exit -1
			fi
			if test -z "${TRAVIS_TAG-}" -a -n "${NPM_VERSION_BUMP-}"; then
				echo "non tag release, so bumping version from the latest..."
				echo "fetching the latest npm version..."
				npm version "$(npm view . version)" --allow-same-version --no-git-tag-version
				echo "bumping the npm version..."
				npm version "${NPM_VERSION_BUMP}"
			fi
			echo "publishing..."
			npm publish --access public
			echo "...released to npm"
		else
			echo "no need for release"
		fi
	else
		echo "running on node version $CURRENT_NODE_VERSION which IS NOT the desired $DESIRED_NODE_VERSION"
		echo "skipping release to npm"
	fi
else
	echo "running on pull request"
	echo "skipping release to npm"
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u
