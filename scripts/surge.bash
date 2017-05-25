#!/bin/bash

# If the tests succeeded, then deploy our release to [Surge](https://surge.sh) URLs for our branch, tag, and commit.
# Useful for rendering documentation and compiling code then deploying the release,
# such that you don't need the rendered documentation and compiled code inside your source repository.
# This is beneficial because sometimes documentation will reference the current commit,
# causing a documentation recompile to always leave a dirty state - this solution avoids that,
# as documentation can be git ignored.
#
#
# Local Installation:
#
# You will need to make sure you have surge installed as a local dependency,
# using npm: npm install --save-dev surge
# using yarn: yarn add --dev surge
#
#
# Installation:
#
# after_success:
#   - eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/surge.bash)"
#
#
# Configuration:
#
# Set your `SURGE_LOGIN` which is your surge.sh username
# travis env set SURGE_LOGIN "$SURGE_LOGIN" --public
#
# Set your `SURGE_TOKEN` (which you can get via the `surge token` command)
# travis env set SURGE_TOKEN "$SURGE_TOKEN"
# 
# Set the path that you want to deploy to surge
# travis env set SURGE_PROJECT "." --public


# Node Development Dependencies:
# surge

# External Environment Variables:
# TRAVIS_REPO_SLUG

# User Environment Variables:
# SURGE_LOGIN
# SURGE_TOKEN
export SURGE_PROJECT
if test -z "$SURGE_PROJECT"; then
	SURGE_PROJECT="."
fi
export DESIRED_NODE_VERSION
if test -z "$DESIRED_NODE_VERSION"; then
	DESIRED_NODE_VERSION="$(nvm version-remote --lts)" || exit -1
else
	DESIRED_NODE_VERSION="$(nvm version-remote "$DESIRED_NODE_VERSION")" || exit -1
fi

# Local Environment Variables:
export CURRENT_NODE_VERSION
CURRENT_NODE_VERSION="$(node --version)" || exit -1

# Run
if test "$CURRENT_NODE_VERSION" = "$DESIRED_NODE_VERSION"; then
	echo "running on node version $CURRENT_NODE_VERSION which IS the desired $DESIRED_NODE_VERSION"
	echo "performing release to surge..."
	echo "preparing release"
	npm run our:meta || exit -1
	echo "performing deploy"
	SURGE_SLUG="$(echo $TRAVIS_REPO_SLUG | sed 's/^\(.*\)\/\(.*\)/\2.\1/')" || exit -1
	if test "$TRAVIS_BRANCH"; then
		echo "deploying branch..."
		surge --project $SURGE_PROJECT --domain "$TRAVIS_BRANCH.$SURGE_SLUG.surge.sh" || exit -1
	fi
	if test "$TRAVIS_TAG"; then
		echo "deploying tag..."
		surge --project $SURGE_PROJECT --domain "$TRAVIS_TAG.$SURGE_SLUG.surge.sh" || exit -1
	fi
	if test "$TRAVIS_COMMIT"; then
		echo "deploying commit..."
		surge --project $SURGE_PROJECT --domain "$TRAVIS_COMMIT.$SURGE_SLUG.surge.sh" || exit -1
	fi
	echo "...released to surge"
else
	echo "running on node version $CURRENT_NODE_VERSION which IS NOT the desired $DESIRED_NODE_VERSION"
	echo "skipping release to surge"
fi
