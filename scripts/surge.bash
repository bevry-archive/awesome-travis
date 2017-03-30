#!/bin/bash

# Node Development Dependencies:
# surge

# External Environment Variables:
# SURGE_PROJECT
# SURGE_LOGIN
# SURGE_TOKEN

# Local Environment Variables:
export CURRENT_NODE_VERSION
export LTS_NODE_LATEST_VERSION
export SURGE_SLUG
CURRENT_NODE_VERSION="$(node --version)" || exit -1
LTS_NODE_LATEST_VERSION="$(nvm version-remote --lts)" || exit -1

if test "$CURRENT_NODE_VERSION" = "$LTS_NODE_LATEST_VERSION"; then
	echo "running on latest LTS node version, performing release to surge..."
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
	echo "running on non-latest LTS node version, skipping release to surge"
fi