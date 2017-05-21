#!/bin/bash

if ([ "$TRAVIS_BRANCH" == "$DEPLOY_BRANCH" ] &&
	[ -z "$TRAVIS_TAG" ] &&
	[ "$TRAVIS_PULL_REQUEST" == "false" ]); then
	echo "deploying..."
	npm run deploy || exit -1
	echo "...deployed"
else
	echo "skipped deploy"
fi
