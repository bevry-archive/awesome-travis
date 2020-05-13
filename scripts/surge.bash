#!/bin/bash
set -ueE -o pipefail

# If the tests succeeded, then deploy our release to [Surge](https://surge.sh) URLs for our branch, tag, and commit.
# Useful for rendering documentation and compiling code then deploying the release,
# such that you don't need the rendered documentation and compiled code inside your source repository.
# This is beneficial because sometimes documentation will reference the current commit,
# causing a documentation recompile to always leave a dirty state - this solution avoids that,
# as documentation can be git ignored.

# SCRIPT
#
# after_success:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/surge.bash)"

# DEPENDENCIES
#
# SURGE
# You will need to make sure you have surge installed as a local dependency,
# using npm: npm install --save-dev surge

# CUSTOM ENVIRONMENT VARIABLES
#
# DESIRED_NODE_VERSION
# Specficy a specific node version (rather than the LTS version)
# travis env set DESIRED_NODE_VERSION "7" --public
#
# SURGE_LOGIN
# Set your `SURGE_LOGIN` which is your surge.sh username
# travis env set SURGE_LOGIN "$SURGE_LOGIN" --public
#
# SURGE_TOKEN
# Set your `SURGE_TOKEN` (which you can get via the `surge token` command)
# travis env set SURGE_TOKEN "$SURGE_TOKEN"
#
# SURGE_PROJECT
# Set the path that you want to deploy to surge
# travis env set SURGE_PROJECT "." --public

# TRAVIS ENVIRONMENT VARIABLES
#
# TRAVIS_REPO_SLUG
# TRAVIS_BRANCH
# TRAVIS_TAG
# TRAVIS_COMMIT
# TRAVIS_PULL_REQUEST


# Default User Environment Variables
if test -z "${SURGE_PROJECT-}"; then
	SURGE_PROJECT="."
fi
if test -z "${DESIRED_NODE_VERSION-}"; then
	DESIRED_NODE_VERSION="$(set +u && nvm version-remote --lts && set -u)"
else
	DESIRED_NODE_VERSION="$(set +u && nvm version-remote "$DESIRED_NODE_VERSION" && set -u)"
fi

# Set Local Environment Variables
CURRENT_NODE_VERSION="$(node --version)"

# Run
if test "$TRAVIS_PULL_REQUEST" != "false"; then
	# PULL REQUEST
	echo "running on pull request"
	echo "skipping release to surge"
elif test "$CURRENT_NODE_VERSION" != "$DESIRED_NODE_VERSION"; then
	# UNDESIRED
	echo "running on node version $CURRENT_NODE_VERSION which IS NOT the desired $DESIRED_NODE_VERSION"
	echo "skipping release to surge"
elif test -z "${SURGE_LOGIN-}" -o -z "${SURGE_TOKEN-}" -o -z "${SURGE_PROJECT-}"; then
	echo "your must provide a SURGE_LOGIN + SURGE_TOKEN + SURGE_PROJECT combination"
	exit 1
else
	# DESIRED
	echo "running on node version $CURRENT_NODE_VERSION which IS the desired $DESIRED_NODE_VERSION"
	echo "performing release to surge..."
	echo "preparing release"
	npm run our:meta
	echo "performing deploy..."
	SURGE_SLUG="$(echo "$TRAVIS_REPO_SLUG" | sed 's/^\(.*\)\/\(.*\)/\2.\1/')"
	if test -n "${TRAVIS_BRANCH-}"; then
		if [[ "$TRAVIS_BRANCH" = *"dependabot"* ]]; then
			echo "running on dependanbot branch"
			echo "skipping release to surge"
		else
			target="$TRAVIS_BRANCH.$SURGE_SLUG.surge.sh"
			echo "deploying branch of project $SURGE_PROJECT to $target"
			surge --project "$SURGE_PROJECT" --domain "$target"
		fi
	fi
	if test -n "${TRAVIS_TAG-}"; then
		target="$TRAVIS_TAG.$SURGE_SLUG.surge.sh"
		echo "deploying tag of project $SURGE_PROJECT to $target"
		surge --project $SURGE_PROJECT --domain "$target"
	fi
	if test "${TRAVIS_COMMIT-}"; then
		target="$TRAVIS_COMMIT.$SURGE_SLUG.surge.sh"
		echo "deploying commit of project $SURGE_PROJECT to $target"
		surge --project $SURGE_PROJECT --domain "$target"
	fi
	echo "...released to surge"
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u
