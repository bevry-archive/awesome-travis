#!/bin/bash

# If the tests succeed on the specified `DEPLOY_BRANCH`, then prepare git for deployment, and then run the `DEPLOY_COMMAND`.
# The `DEPLOY_COMMAND` should be the command responsible for the compilation, git add, git commit, and git push.
#
#
# Installation:
#
# after_success:
#   - eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/deploy-git.bash)"
#
#
# Configuration:
#
# The branch name that you want tested and deployed, set correctly:
# travis env set DEPLOY_BRANCH "master" --public
#
# The command that will do the compilation and git push:
# travis env set DEPLOY_COMMAND "npm run deploy" --public
#
# Your git username:
# travis env set DEPLOY_USER "$GITHUB_USERNAME" --public
#
# Your git password, if using GitHub, this should probably be a new [GitHub Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) with the `repo` permission:
# travis env set DEPLOY_TOKEN "$GITHUB_TOKEN"
# 
# The name hat is used for the deployment commit, set to whatever:
# travis env set DEPLOY_NAME "Travis CI Deployer" --public
#
# The email that is used for the deployment commit, set to whatever:
# travis env set DEPLOY_EMAIL "deployer@travis-ci.org" --public


# User Environment Variables:
# DEPLOY_EMAIL
# DEPLOY_NAME
# DEPLOY_USER
# DEPLOY_TOKEN
# DEPLOY_BRANCH
# DEPLOY_COMMAND

if ([ "$TRAVIS_BRANCH" == "$DEPLOY_BRANCH" ] &&
	[ -z "$TRAVIS_TAG" ] &&
	[ "$TRAVIS_PULL_REQUEST" == "false" ]); then
	echo "deploying..."
	git config --global user.email "$DEPLOY_EMAIL" || exit -1
	git config --global user.name "$DEPLOY_NAME" || exit -1
	git remote rm origin || exit -1
	git remote add origin "https://$DEPLOY_USER:$DEPLOY_TOKEN@github.com/$TRAVIS_REPO_SLUG.git" || exit -1
	eval "$DEPLOY_COMMAND" || exit -1
	echo "...deployed"
else
	echo "skipped deploy"
fi
