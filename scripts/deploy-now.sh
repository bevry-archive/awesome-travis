#!/bin/bash

# If the tests succeed on the specified `DEPLOY_BRANCH`, then deploy with https://zeit.co/now
#
#
# Installation:
#
# after_success:
#   - eval "$(curl -s https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/deploy-now.bash)"
#
#
# Configuration:
#
# The branch name that you want tested and deployed (defaults to `master`)
# travis env set DEPLOY_BRANCH "master" --public
#
# Your now token. You can create one here: https://zeit.co/account/tokens
# travis env set NOW_TOKEN "$NOW_TOKEN"
#
# Your now team, if applicable. You can fetch your teams via the `now teams list` command.
# travis env set NOW_TEAM "$NOW_TEAM"

export DEPLOY_BRANCH
if test -z "$DEPLOY_BRANCH"; then
	DEPLOY_BRANCH="master"
fi

if ([ "$TRAVIS_BRANCH" == "$DEPLOY_BRANCH" ] &&
	[ -z "$TRAVIS_TAG" ] &&
	[ "$TRAVIS_PULL_REQUEST" == "false" ]); then
	echo "deploying..."
  if [ -z "$NOW_TEAM" ]; then
    now --token "$NOW_TOKEN" teams switch "$NOW_TEAM" || exit -1
  fi
  now --token "$NOW_TOKEN" || exit -1
  now --token "$NOW_TOKEN" alias || exit -1
	echo "...deployed"
else
	echo "skipped deploy"
fi
