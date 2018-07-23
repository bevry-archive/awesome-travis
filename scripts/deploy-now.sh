#!/bin/bash
set -ueE -o pipefail

# If the tests succeed on the specified `DEPLOY_BRANCH`, then deploy with https://zeit.co/now

# TRAVIS SCRIPT
#
# after_success:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/deploy-now.bash)"

# DEPENDENCIES
#
# You will need to make sure you have now installed as a local dependency,
# using npm: npm install --save-dev now

# TRAVIS ENVIRONMENT VARIABLES
#
# DEPLOY_BRANCH
# The branch name that you want tested and deployed (defaults to `master`)
# travis env set DEPLOY_BRANCH "master" --public
#
# NOW_TOKEN
# Your now token. You can create one here: https://zeit.co/account/tokens
# travis env set NOW_TOKEN "$NOW_TOKEN"
#
# NOW_TEAM
# Your now team, if applicable. You can fetch your teams via the `now teams list` command.
# travis env set NOW_TEAM "$NOW_TEAM"

# EXTERNAL ENVIRONMENT VARIABLES
#
# TRAVIS_BRANCH
# TRAVIS_TAG
# TRAVIS_PULL_REQUEST

# Default User Environment Variables
if test -z "${DEPLOY_BRANCH-}"; then
	DEPLOY_BRANCH="master"
fi

# Run
if test "${TRAVIS_BRANCH-}" = "$DEPLOY_BRANCH" -a -z "${TRAVIS_TAG-}" -a "$TRAVIS_PULL_REQUEST" = "false"; then
	echo "deploying..."
	if test -z "${NOW_TEAM-}"; then
		now --token "$NOW_TOKEN" teams switch "$NOW_TEAM"
	fi
	now --token "$NOW_TOKEN"
	now --token "$NOW_TOKEN" alias
	echo "...deployed"
else
	echo "skipped deploy"
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u