# awesome-travis

Crowd-sourced list of [Travis CI](https://travis-ci.org) hooks/scripts etc to level up your `.travis.yml` file


## Notifications

### Slack

```
# https://github.com/balupton/awesome-travis#slack
travis encrypt --org "$SLACK_SUBDOMAIN:$SLACK_TRAVIS_TOKEN#updates" --add notifications.slack
```

Used by [bevry/base](https://github.com/bevry/base)


### Email

```
# https://github.com/balupton/awesome-travis#email
travis encrypt --org "$TRAVIS_NOTIFICATION_EMAIL" --add notifications.email.recipients
```

Used by [bevry/base](https://github.com/bevry/base)


## Node.js

### Complete Node.js Version Matrix

Complete configuration for the different [node.js versions](https://github.com/nodejs/LTS) one may need to support. With legacy versions allowed to fail.

``` yaml
# Complete Node.js Version Matrix
# https://github.com/balupton/awesome-travis#complete-nodejs-version-matrix
language: node_js
node_js:
  - "0.8"   # end of life
  - "0.10"  # end of life
  - "0.12"  # maintenance
  - "4"     # lts
  - "6"     # lts
  - "7"     # stable
matrix:
  fast_finish: true
  allow_failures:
    - node_js: "0.8"
    - node_js: "0.10"
cache:
  directories:
    - node_modules
```

Used by [bevry/base](https://github.com/bevry/base)


### Ensure NPM is latest

``` yaml
install: |
  # Ensure NPM is latest
  # https://github.com/balupton/awesome-travis#ensure-npm-is-latest
  export CURRENT_NPM_VERSION="$(npm --version)"
  export LATEST_NPM_VERSION="$(npm view npm version)"
  if test "$CURRENT_NPM_VERSION" != "$LATEST_NPM_VERSION"; then
    echo "running an old npm version, upgrading npm..."
    npm instal npm --global --cache-min=Infinity
    echo "...npm upgrade complete
  fi
```

Used by [bevry/base](https://github.com/bevry/base)


### Use LTS node version for preparation

``` yaml
install: |
  # Ensure dependencies install with a LTS node version
  # https://github.com/balupton/awesome-travis#use-lts-node-version-for-preparation
  export CURRENT_NODE_VERSION="$(node --version)"
  export LTS_NODE_VERSIONS="$(nvm ls-remote --lts)"
  if echo "$LTS_NODE_VERSIONS" | grep "$CURRENT_NODE_VERSION"; then
    echo "running on a LTS node version, completing setup..."
    npm run our:setup
    echo "...setup complete with current LTS version"
  else
    echo "running on a non-LTS node version, completing setup on a LTS node version..."
    nvm install --lts
    export LTS_NODE_INSTALLED_VERSION="$(node --version)"
    npm run our:setup
    nvm use "$TRAVIS_NODE_VERSION"
    echo "...setup complete with LTS"
  fi

before_script: |
  # Ensure compilation and linting occur on a LTS node version
  # https://github.com/balupton/awesome-travis#use-lts-node-version-for-preparation
  if test "$LTS_NODE_INSTALLED_VERSION"; then
    echo "running on a non-LTS node version, compiling with LTS, skipping linting..."
    nvm use "$LTS_NODE_INSTALLED_VERSION"
    npm run our:compile
    nvm use "$TRAVIS_NODE_VERSION"
    echo "...compiled"
  else
    echo "running on a LTS node version, compiling and linting..."
    npm run our:compile && npm run our:verify
    echo "...compiled and linted"
  fi
```

Used by [bevry/base](https://github.com/bevry/base)


## Deployment

### Rerun another project's tests

Useful for when you have a content repository, which when updated, you want to rebuild the website/render repository.

``` yaml
after_success: |
  # Rerun another project's tests
  # https://github.com/balupton/awesome-travis#rerun-another-projects-tests
  if [ ! -z $GITHUB_TRAVIS_TOKEN ]; then
    echo "Pinging $DEPLOY_REPO_SLUG...";
    rvm install 2.1;
    gem install travis curb --no-rdoc --no-ri;
    travis login --skip-completion-check --org --github-token "$GITHUB_TRAVIS_TOKEN";
    export TRAVIS_ACCESS_TOKEN=`cat ~/.travis/config.yml | grep access_token | sed 's/ *access_token: *//'`;
    travis restart --debug --skip-completion-check --org -r "$DEPLOY_REPO_SLUG" -t "$TRAVIS_ACCESS_TOKEN";
    echo "Pinged $DEPLOY_REPO_SLUG";
  else
    echo "Skipped ping $DEPLOY_REPO_SLUG";
  fi

# Custom Configuration
env:
  global:
    # Deployment Environment Variables
    # travis encrypt "GITHUB_TRAVIS_TOKEN=$GITHUB_TRAVIS_TOKEN" --add env.global
    - DEPLOY_REPO_SLUG='bevry/staticsitegenerators-website'  # this is the repo owner and repo name that you want tested and deployed, set correctly
```

This should be easier but https://github.com/travis-ci/travis.rb/issues/315 is a thing. Also don't use --debug on `travis login` as that will output the github token.

Used by [bevry/staticsitegenerators-list](https://github.com/bevry/staticsitegenerators-list)


### Git + NPM Script Deployment

If the tests succeeded on the branch that we deploy, then prepare git for a push and runs the custom [npm script](https://docs.npmjs.com/misc/scripts) `our:deploy` after a successful test. The `our:deploy` script should be something that generates your website and runs a `git push origin`. Useful for [GitHub Pages](https://pages.github.com) deployments.

Create your `DEPLOY_TOKEN` by creating a [GitHub Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) with the `repo` permission.

``` yaml
# Deployment
after_success: |
  # Git + NPM Script Deployment
  # https://github.com/balupton/awesome-travis#git--npm-script-deployment
  if ([ ! -z "$DEPLOY_TOKEN" ] &&
      [ "$TRAVIS_BRANCH" == "$DEPLOY_BRANCH" ] &&
      [ -z "$TRAVIS_TAG" ] &&
      [ "$TRAVIS_PULL_REQUEST" == "false" ]); then
    echo "Deploying";
    git config --global user.email "$DEPLOY_EMAIL";
    git config --global user.name "$DEPLOY_NAME";
    git remote rm origin;
    git remote add origin "https://$DEPLOY_USER:$DEPLOY_TOKEN@github.com/$TRAVIS_REPO_SLUG.git";
    npm run our:deploy;
    echo "Deployed";
  else
    echo "Skipped deploy"
  fi
 
# Custom Configuration
env:
  global:
    # Deployment Environment Variables
    # travis encrypt "DEPLOY_USER=$GITHUB_USERNAME" --add env.global
    # travis encrypt "DEPLOY_TOKEN=$GITHUB_TRAVIS_TOKEN" --add env.global
    - DEPLOY_BRANCH='master'  # this is the branch name that you want tested and deployed, set correctly
    - DEPLOY_NAME='Travis CI Deployer'  # this is the name that is used for the deployment commit, set to whatever
    - DEPLOY_EMAIL='deployer@travis-ci.org'  # this is the email that is used for the deployment commit, set to whatever
```

Used by [bevry/staticsitegenerators-website](https://github.com/bevry/staticsitegenerators-website)


### Release to Surge

If the tests succeeded, then deploy our release to [Surge](https://surge.sh) URLs for our branch, tag, and commit. Useful for rendering documentation and compiling code then deploying the release, such that you don't need the rendered documentation and compiled code inside your source repository. This is beneficial because sometimes documentation will reference the current commit, causing a documentation recompile to always leave a dirty state - this solution avoids that, as documentation can be git ignored.

Fetch your `SURGE_TOKEN` via the `surge token` command.

``` yaml
after_success: |
  # Release to Surge
  # travis encrypt "SURGE_LOGIN=$SURGE_LOGIN" --add env.global
  # travis encrypt "SURGE_TOKEN=$SURGE_TOKEN" --add env.global
  export CURRENT_NODE_VERSION="$(node --version)"
  export LTS_NODE_LATEST_VERSION="$(nvm version-remote --lts)"
  if test "$CURRENT_NODE_VERSION" = "$LTS_NODE_LATEST_VERSION"; then
    echo "running on latest LTS node version, performing release to surge..."
    echo "preparing release"
    npm run our:meta
    echo "installing surge"
    npm install surge
    echo "performing deploy"
    export SURGE_SLUG="$(echo $TRAVIS_REPO_SLUG | sed 's/^\(.*\)\/\(.*\)/\2.\1/')"
    if test "$TRAVIS_BRANCH"; then
      echo "deploying branch..."
      surge --project . --domain "$TRAVIS_BRANCH.$SURGE_SLUG.surge.sh"
    fi
    if test "$TRAVIS_TAG"; then
      echo "deploying tag..."
      surge --project . --domain "$TRAVIS_TAG.$SURGE_SLUG.surge.sh"
    fi
    if test "$TRAVIS_COMMIT"; then
      echo "deploying commit..."
      surge --project . --domain "$TRAVIS_COMMIT.$SURGE_SLUG.surge.sh"
    fi
    echo "...released to surge"
  else
    echo "running on non-latest LTS node version, skipping release to surge"
  fi
```

Used by [bevry/base](https://github.com/bevry/base) with example at [bevry/badges](https://github.com/bevry/badges)


### Release to NPM

If the tests succeeded and travis is running on a tag and on the latest node.js LTS version, then perform an `npm publish`. Useful such that git tags can be published to npm, allowing any contributor to git able to do npm releases. When combined with other npm scripts, this can help automate a lot.

``` yaml
after_success: |
  # Release to NPM
  # travis encrypt "NPM_USERNAME=$NPM_USERNAME" --add env.global
  # travis encrypt "NPM_PASSWORD=$NPM_PASSWORD" --add env.global
  # travis encrypt "NPM_EMAIL=$NPM_EMAIL" --add env.global
  export CURRENT_NODE_VERSION="$(node --version)"
  export LTS_NODE_LATEST_VERSION="$(nvm version-remote --lts)"
  if test "$CURRENT_NODE_VERSION" = "$LTS_NODE_LATEST_VERSION"; then
    if test "$TRAVIS_TAG"; then
      echo "logging in..."
      echo -e "$NPM_USERNAME\n$NPM_PASSWORD\n$NPM_EMAIL" | npm login
      echo "publishing..."
      npm publish
      echo "...released to npm"
    else
      echo "non-tag, no need for release"
    fi
  else
    echo "running on non-latest LTS node version, skipping release to npm"
  fi
```

Used by [bevry/base](https://github.com/bevry/base) with example at [bevry/badges](https://github.com/bevry/badges)


## Contribution

Add headings to the appropriate sections or make a new section with your Travis CI nifties.

Use a part? feel free to add yourself to the `Used by` lists.

To keep the spirit of collaboration going, anyone who gets a pull request merged will get commit access.

Avoid changing header titles, as people may reference them when they use parts.


## License

Public Domain via The Unlicense
