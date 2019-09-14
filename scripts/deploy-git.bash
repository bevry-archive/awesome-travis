#!/bin/bash
set -ueE -o pipefail

# If the tests succeed on the specified `DEPLOY_BRANCH`, then prepare git for deployment, and then run the `DEPLOY_COMMAND`.
# The `DEPLOY_COMMAND` should be the command responsible for the compilation, git add, git commit, and git push.

# SCRIPT
#
# after_success:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/deploy-git.bash)"

# CUSTOM ENVIRONMENT VARIABLES
#
# DEPLOY_BRANCH
# The branch name that you want tested and deployed, set correctly:
# travis env set DEPLOY_BRANCH "master" --public
#
# DEPLOY_COMMAND
# The command that will do the compilation and git push:
# travis env set DEPLOY_COMMAND "npm run deploy" --public
#
# DEPLOY_USER
# Your git username:
# travis env set DEPLOY_USER "$GITHUB_USERNAME" --public
#
# DEPLOY_TOKEN
# Your git password, if using GitHub, this should probably be a new [GitHub Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) with the `repo` permission:
# travis env set DEPLOY_TOKEN "$GITHUB_TOKEN"
#
# DEPLOY_NAME
# The name hat is used for the deployment commit, set to whatever:
# travis env set DEPLOY_NAME "Travis CI Deployer" --public
#
# DEPLOY_EMAIL
# The email that is used for the deployment commit, set to whatever:
# travis env set DEPLOY_EMAIL "deployer@travis-ci.org" --public

# TRAVIS ENVIRONMENT VARIABLES
#
# TRAVIS_BRANCH
# TRAVIS_TAG
# TRAVIS_PULL_REQUEST
# TRAVIS_REPO_SLUG

# Run
if test "${TRAVIS_BRANCH-}" = "$DEPLOY_BRANCH" -a -z "${TRAVIS_TAG-}" -a "$TRAVIS_PULL_REQUEST" = "false"; then
	echo "deploying..."
	git config --global user.email "$DEPLOY_EMAIL"
	git config --global user.name "$DEPLOY_NAME"
	git remote rm origin
	git remote add origin "https://$DEPLOY_USER:$DEPLOY_TOKEN@github.com/$TRAVIS_REPO_SLUG.git"
	eval "$DEPLOY_COMMAND"
	echo "...deployed"
else
	echo "skipped deploy"
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u