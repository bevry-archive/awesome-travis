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

### Version Matrix

Complete configuration for the different [node.js versions](https://github.com/nodejs/LTS) one may need to support. With legacy versions allowed to fail.

``` yaml
# https://github.com/balupton/awesome-travis#version-matrix
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
    echo "running an old npm version, upgrading"
    npm instal npm --global --cache-min=Infinity
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
    echo "running on a LTS node version, completing setup"
    npm run our:setup
  else
    echo "running on a non-LTS node version, completing setup on a LTS node version"
    nvm install --lts
    export LTS_NODE_VERSION="$(node --version)"
    npm run our:setup
    nvm use "$TRAVIS_NODE_VERSION"
  fi
  
  # Ensure compilation and linting occur on a LTS node version
  # https://github.com/balupton/awesome-travis#use-lts-node-version-for-preparation
  if test "$LTS_NODE_VERSION"; then
    echo "running on a non-LTS node version, compiling with LTS, skipping linting"
    nvm use "$LTS_NODE_VERSION"
    npm run our:compile
    nvm use "$TRAVIS_NODE_VERSION"
  else
    echo "running on a LTS node version, compiling and linting"
    npm run our:compile && npm run our:verify
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

If the tests ran on the branch that we deploy, then prepare git for a push and runs the custom [npm script](https://docs.npmjs.com/misc/scripts) `our:deploy` after a successful test. The `our:deploy` script should be something that generates your website and runs a `git push origin`. Useful for [GitHub Pages](https://pages.github.com) deployments.


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


## Contribution

Add headings to the appropriate sections or make a new section with your Travis CI nifties.

Use a part? feel free to add yourself to the `Used by` lists.

To keep the spirit of collaboration going, anyone who gets a pull request merged will get commit access.

Avoid changing header titles, as people may reference them when they use parts.


## License

Public Domain via The Unlicense
