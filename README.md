# awesome-travis

Crowd-sourced list of [Travis CI](https://travis-ci.org) hooks/scripts etc to level up your `.travis.yml` file

## Tips

The scripts in this repository are their own files, which the latest are fetched. E.g.

``` yaml
install:
  - curl https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/npm-upgrade.bash | bash || exit -1
```

You probably want to change the `master` to the the current commit hash. For instance:

``` yaml
install:
  - curl https://raw.githubusercontent.com/balupton/awesome-travis/some-commit-hash-instead/scripts/npm-upgrade.bash | bash || exit -1
```

Or you could even download it into a `.travis` folder for local use instead:

``` bash
mkdir -p ./.travis
wget https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/npm-upgrade.bash ./.travis/npm-upgrade.bash
chmod +x ./.travis/npm-upgrade.bash
```

``` yaml
install:
  - ./.travis/npm-upgrade.bash || exit -1
```


## Notifications

### Slack

``` bash
travis encrypt "$SLACK_SUBDOMAIN:$SLACK_TRAVIS_TOKEN#updates" --add notifications.slack
```

Used by [bevry/base](https://github.com/bevry/base)


### Email

``` bash
travis encrypt "$TRAVIS_NOTIFICATION_EMAIL" --add notifications.email.recipients
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
    - $HOME/.npm  # npm's cache
    - $HOME/.yarn-cache  # yarn's cache
```

Used by [bevry/base](https://github.com/bevry/base)


### Ensure NPM is latest

``` yaml
# travis configuration
install:
  - curl https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/npm-upgrade.bash | bash || exit -1
```

Used by [bevry/base](https://github.com/bevry/base)


### Use LTS node version for preparation

``` yaml
# travis configuration
install:
  - curl https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/npm-install.bash | bash || exit -1
before_script:
  - curl https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/npm-verify.bash | bash || exit -1
```

Used by [bevry/base](https://github.com/bevry/base)


## Deployment

### Rerun another project's tests

Useful for when you have a content repository that is used by a different repository, and as such, when the content repository changes, you want to rerun the tests for the other repository, perhaps even for deployment purposes.

Create your `GITHUB_TRAVIS_TOKEN` by creating a [GitHub Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) with the `repo` permission.

``` bash
# configuration commands
travis env set GITHUB_TRAVIS_TOKEN "$GITHUB_TRAVIS_TOKEN"
travis env set OTHER_REPO_SLUG "bevry/staticsitegenerators-website" --private
```

``` yaml
# travis configuration
after_success:
  - curl https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/travis-another.bash | bash || exit -1
```

Used by [bevry/staticsitegenerators-list](https://github.com/bevry/staticsitegenerators-list)


### Git + NPM Script Deployment

If the tests succeeded on the branch that we deploy, then prepare git for a push and runs the custom [npm script](https://docs.npmjs.com/misc/scripts) `our:deploy` after a successful test. The `our:deploy` script should be something that generates your website and runs a `git push origin`. Useful for [GitHub Pages](https://pages.github.com) deployments.

Create your `GITHUB_TRAVIS_TOKEN` by creating a [GitHub Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) with the `repo` permission.

``` bash
# configuration commands
travis env set DEPLOY_USER "$GITHUB_USERNAME"
travis env set DEPLOY_TOKEN "$GITHUB_TRAVIS_TOKEN"

# this is the branch name that you want tested and deployed, set correctly
travis env set DEPLOY_BRANCH "master" --public
# this is the name that is used for the deployment commit, set to whatever
travis env set DEPLOY_NAME "Travis CI Deployer" --public
# this is the email that is used for the deployment commit, set to whatever
travis env set DEPLOY_EMAIL "deployer@travis-ci.org" --public
```

``` yaml
# travis configuration
after_success:
  - curl https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/github-pages.bash | bash || exit -1
```

Used by [bevry/staticsitegenerators-website](https://github.com/bevry/staticsitegenerators-website)


### Release to Surge

If the tests succeeded, then deploy our release to [Surge](https://surge.sh) URLs for our branch, tag, and commit. Useful for rendering documentation and compiling code then deploying the release, such that you don't need the rendered documentation and compiled code inside your source repository. This is beneficial because sometimes documentation will reference the current commit, causing a documentation recompile to always leave a dirty state - this solution avoids that, as documentation can be git ignored.

Fetch your `SURGE_TOKEN` via the `surge token` command.

``` bash
# configuration commands
travis env set SURGE_LOGIN "$SURGE_LOGIN"
travis env set SURGE_TOKEN "$SURGE_TOKEN"

# this is the path that you want to deploy to surge
travis env set SURGE_PROJECT "." --public

# make sure surge exists as a npm development dependency
npm install --save-dev surge
# or if you are using yarn
yarn add --dev surge
```

``` yaml
# travis configuration
after_success:
  - curl https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/surge.bash | bash || exit -1
```

Used by [bevry/base](https://github.com/bevry/base) with example at [bevry/badges](https://github.com/bevry/badges)


### Release to NPM

If the tests succeeded and travis is running on a tag and on the latest node.js LTS version, then perform an `npm publish`. Useful such that git tags can be published to npm, allowing any contributor to git able to do npm releases. When combined with other npm scripts, this can help automate a lot.

``` bash
# configuration commands
travis env set NPM_USERNAME "$NPM_USERNAME"
travis env set NPM_PASSWORD "$NPM_PASSWORD"
travis env set NPM_EMAIL "$NPM_EMAIL"
```

``` yaml
# travis configuration
after_success:
  - curl https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/npm-publish.bash | bash || exit -1
```

Used by [bevry/base](https://github.com/bevry/base) with example at [bevry/badges](https://github.com/bevry/badges)


## Contribution

Add headings to the appropriate sections or make a new section with your Travis CI nifties.

Use a part? feel free to add yourself to the `Used by` lists.

To keep the spirit of collaboration going, anyone who gets a pull request merged will get commit access.

Avoid changing header titles, as people may reference them when they use parts.


## License

Public Domain via The Unlicense
