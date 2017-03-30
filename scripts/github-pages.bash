#!/bin/bash

# User Environment Variables:
# DEPLOY_EMAIL
# DEPLOY_NAME
# DEPLOY_USER
# DEPLOY_TOKEN
# DEPLOY_BRANCH

if ([ ! -z "$DEPLOY_TOKEN" ] &&
	[ "$TRAVIS_BRANCH" == "$DEPLOY_BRANCH" ] &&
	[ -z "$TRAVIS_TAG" ] &&
	[ "$TRAVIS_PULL_REQUEST" == "false" ]); then
	echo "deploying..."
	git config --global user.email "$DEPLOY_EMAIL" || exit -1
	git config --global user.name "$DEPLOY_NAME" || exit -1
	git remote rm origin || exit -1
	git remote add origin "https://$DEPLOY_USER:$DEPLOY_TOKEN@github.com/$TRAVIS_REPO_SLUG.git" || exit -1
	npm run deploy || exit -1
	echo "...deployed"
else
	echo "skipped deploy"
fi