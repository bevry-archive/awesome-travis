#!/bin/bash
set -ueE -o pipefail

# If the tests succeed on the specified `DEPLOY_BRANCH`, then prepare git for deployment, and then run the `DEPLOY_COMMAND`.

# SCRIPT
#
# after_success:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/deploy-custom.bash)"

# CUSTOM ENVIRONMENT VARIABLES
#
# DEPLOY_BRANCH
# The branch name that you want tested and deployed, set correctly:
# travis env set DEPLOY_BRANCH "master" --public
#
# DEPLOY_COMMAND
# The command that will do the compilation and git push:
# travis env set DEPLOY_COMMAND "npm run our:deploy" --public

# TRAVIS ENVIRONMENT VARIABLES
#
# TRAVIS_BRANCH
# TRAVIS_TAG
# TRAVIS_PULL_REQUEST

# Default User Environment Variables
if test -z "${DEPLOY_BRANCH-}"; then
	DEPLOY_BRANCH="master"
fi
if test -z "${DEPLOY_COMMAND-}"; then
	DEPLOY_COMMAND="npm run our:deploy"
fi

# Run
if test "${TRAVIS_BRANCH-}" = "$DEPLOY_BRANCH" -a -z "${TRAVIS_TAG-}" -a "$TRAVIS_PULL_REQUEST" = "false"; then
	echo "deploying..."
	eval "$DEPLOY_COMMAND"
	echo "...deployed"
else
	echo "skipped deploy"
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u
