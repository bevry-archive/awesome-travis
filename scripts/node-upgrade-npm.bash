#!/bin/bash
set -ueE -o pipefail

# Installs the latest supported version of npm for the current node version, using nvm's `install-latest-npm` command.

# SCRIPT
#
# before_install:
#   - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-upgrade-npm.bash)"

# TRAVIS ENVIRONMENT VARIABLES
#
# TRAVIS_NODE_VERSION

# avoid ssl errors
case "${TRAVIS_NODE_VERSION}" in 0.*) export NPM_CONFIG_STRICT_SSL=false ;; esac
# install latest npm for current node version using nvm's code to do so
set +u && nvm install-latest-npm && set -u

# while our scripts pass linting, other scripts may not
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u
