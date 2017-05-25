#!/bin/bash

# If the tests succeed on the specified `DEPLOY_BRANCH`, then prepare git for deployment, and then run the `DEPLOY_COMMAND`.
#
#
# Installation:
#
# after_success:
#   - eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/custom-deploy.bash)"
#
#
# Configuration:
#
# The branch name that you want tested and deployed, set correctly:
# travis env set DEPLOY_BRANCH "master" --public
#
# The command that will do the compilation and git push:
# travis env set DEPLOY_COMMAND "npm run deploy" --public


# User Environment Variables:
# DEPLOY_BRANCH
# DEPLOY_COMMAND

if ([ "$TRAVIS_BRANCH" == "$DEPLOY_BRANCH" ] &&
	[ -z "$TRAVIS_TAG" ] &&
	[ "$TRAVIS_PULL_REQUEST" == "false" ]); then
	echo "deploying..."
	eval "$DEPLOY_COMMAND" || exit -1
	echo "...deployed"
else
	echo "skipped deploy"
fi
