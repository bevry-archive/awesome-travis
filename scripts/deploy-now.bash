#!/bin/bash
set -ueE -o pipefail

# If the tests succeed on the specified `DEPLOY_BRANCH`, then deploy with https://zeit.co/now

# SCRIPT
#
# after_success:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/deploy-now.bash)"

# DEPENDENCIES
#
# You will need to make sure you have now installed as a local dependency,
# using npm: npm install --save-dev now

# CUSTOM ENVIRONMENT VARIABLES
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
# travis env set NOW_TEAM "$NOW_TEAM" --public

# TRAVIS ENVIRONMENT VARIABLES
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
	# don't install now if it doesn't exist, as version differences can be a problem
	echo "deploying..."
	if test -n "${NOW_TEAM-}"; then
		now --token "$NOW_TOKEN" --team "$NOW_TEAM"
		now alias --token "$NOW_TOKEN" --team "$NOW_TEAM"
	else
		now --token "$NOW_TOKEN"
		now alias --token "$NOW_TOKEN"
	fi
	echo "...deployed"
else
	echo "skipped deploy"
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u
