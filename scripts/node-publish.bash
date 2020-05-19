#!/bin/bash
set -ueE -o pipefail

# Use the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version) to login with npm and run `npm publish`.

# SCRIPT
#
# after_success:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-publish.bash)"

# CUSTOM ENVIRONMENT VARIABLES
#
# DESIRED_NODE_VERSION
# Specficy a specific node version (rather than the LTS version)
# travis env set DESIRED_NODE_VERSION "7" --public
#
# NPM_AUTHTOKEN
# Specify your npm token (you can use this instead of the npm username+password+email)
# travis env set NPM_AUTHTOKEN "$NPM_AUTHTOKEN"
#
# NPM_USERNAME
# Specify your npm username:
# travis env set NPM_USERNAME "$NPM_USERNAME" --public
#
# NPM_PASSWORD
# Specify your npm password
# travis env set NPM_PASSWORD "$NPM_PASSWORD"
#
# NPM_EMAIL
# Specify your npm email
# travis env set NPM_EMAIL "$NPM_EMAIL"
#
# NPM_BRANCH_TAG
# Specify which branch should be published to npm as which tag
# travis env set NPM_BRANCH_TAG "master:next"
#
# BEVRY_CDN_TOKEN
# Specify the token for publishing to the bevry CDN
# travis env set BEVRY_CDN_TOKEN "$BEVRY_CDN_TOKEN"

# TRAVIS ENVIRONMENT VARIABLES
#
# TRAVIS_REPO_SLUG
# TRAVIS_JOB_ID
# TRAVIS_BRANCH
# TRAVIS_TAG
# TRAVIS_PULL_REQUEST

# Default User Environment Variables
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
	echo "skipping release to npm"
elif test "$CURRENT_NODE_VERSION" != "$DESIRED_NODE_VERSION"; then
	# UNDESIRED
	echo "running on node version $CURRENT_NODE_VERSION which IS NOT the desired $DESIRED_NODE_VERSION"
	echo "skipping release to npm"
else
	# DESIRED
	echo "running on node version $CURRENT_NODE_VERSION which IS the desired $DESIRED_NODE_VERSION"

	# check if we wish to tag the current branch
	if test -n "${NPM_BRANCH_TAG:-}"; then
		branch="${NPM_BRANCH_TAG%:*}"
		if test "$branch" = "$TRAVIS_BRANCH"; then
			tag="${NPM_BRANCH_TAG#*:}"
		fi
	fi

	if test -n "${NPM_VERSION_BUMP-}" -o -n "${TRAVIS_TAG-}" -o -n "${tag-}"; then
		echo "releasing to npm..."

		# login
		if test -n "${NPM_AUTHTOKEN-}"; then
			echo "creating npmrc with auth token..."
			echo "//registry.npmjs.org/:_authToken=$NPM_AUTHTOKEN" > "$HOME/.npmrc"
		elif test -n "${NPM_USERNAME-}" -a -n "${NPM_PASSWORD-}"; then
			echo "logging in..."
			env NPM_USER="$NPM_USERNAME" NPM_PASS="$NPM_PASSWORD" npx npm-login-cmd
		else
			echo "your must provide NPM_AUTHTOKEN or a (NPM_USERNAME, NPM_PASSWORD, NPM_EMAIL) combination"
			exit 1
		fi

		# not travis tag, is branch tag
		if test -z "${TRAVIS_TAG-}" -a -n "${tag-}"; then
			echo "bumping the npm version..."
			version="$(node -e "console.log(require('./package.json').version)")"
			commit="$(git rev-parse HEAD)"
			time="$(date +%s)"
			next="${version%-*}-${tag}.${time}.${commit}"  # version trims anything after -
			npm version "${next}" --git-tag-version=false
			echo "publishing branch ${branch} to tag ${tag} with version ${next}..."
			npm publish --access public --tag "${tag}"

		# publish package.json
		else
			echo "publishing the local package.json version..."
			npm publish --access public
		fi

		echo "...released to npm"
	else
		echo "no need for release"
	fi

	# publish to bevry cdn
	if test -n "${BEVRY_CDN_TOKEN-}"; then
		echo 'publishing to bevry cdn...'

		echo "building meta..."
		npm run our:meta

		echo "prepping for cdn..."
		f="./.npmignore"
		n="$(mktemp)"
		o="$(mktemp)"
		node -e "process.stdout.write(require('fs').readFileSync('$f', 'utf8').replace(/# [-=\s]+# CDN Inclusions.+?[^#][^ ][^-=]+/, ''))" > "$n"
		mv "$f" "$o"
		mv "$n" "$f"

		echo "versioning for cdn..."
		tag="cdn"
		version="$(node -e "process.stdout.write(require('./package.json').version)")"
		time="$(date +%s)"
		cdn="${version%-*}-${tag}.${time}.${TRAVIS_JOB_ID}"  # version trims anything after -
		npm version "${cdn}" --git-tag-version=false

		echo "publishing to tag ${tag} with version ${cdn}..."
		npm publish --access public --tag "${tag}"

		echo "adding cdn aliases..."
		packageName="$(node -e "process.stdout.write(require('./package.json').name)")"
		repoName="${TRAVIS_REPO_SLUG#*/}"
		target="${packageName}@${cdn}"

		if test -n "${TRAVIS_BRANCH-}"; then
			if [[ "$TRAVIS_BRANCH" = *"dependabot"* ]]; then
				echo "running on dependanbot branch"
				echo "skipping cdn branch alias"
			else
				echo "aliasing $repoName/$TRAVIS_BRANCH to ${target}"
				curl -d "alias=$repoName/$TRAVIS_BRANCH" -d "target=${target}" -d "token=${BEVRY_CDN_TOKEN}" https://cdn.bevry.me
			fi
		fi
		if test -n "${TRAVIS_TAG-}"; then
			echo "aliasing $repoName/$TRAVIS_TAG to ${target}"
			curl -d "alias=$repoName/$TRAVIS_TAG" -d "target=${target}" -d "token=${BEVRY_CDN_TOKEN}" https://cdn.bevry.me
		fi
		if test -n "${TRAVIS_COMMIT-}"; then
			echo "aliasing $repoName/$TRAVIS_COMMIT to ${target}"
			curl -d "alias=$repoName/$TRAVIS_COMMIT" -d "target=${target}" -d "token=${BEVRY_CDN_TOKEN}" https://cdn.bevry.me
		fi

		echo 'resetting cdn changes...'
		git reset --hard

		echo '...published to bevry cdn'
	fi
fi

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u
