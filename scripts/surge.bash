#!/bin/bash

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
