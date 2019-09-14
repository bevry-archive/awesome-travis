# awesome-travis

Crowd-sourced list of [Travis CI](https://travis-ci.org) hooks/scripts etc to level up your `.travis.yml` file

## Notifications

### Slack

```bash
travis encrypt "$SLACK_SUBDOMAIN:$SLACK_TRAVIS_TOKEN#updates" --add notifications.slack
```

### Email

```bash
travis encrypt "$TRAVIS_NOTIFICATION_EMAIL" --add notifications.email.recipients
```

## Node.js

### Complete Node.js Version Matrix

Complete configuration for the different [node.js versions](https://github.com/nodejs/LTS) one may need to support. With legacy versions allowed to fail.

```yaml
# https://github.com/bevry/awesome-travis
# https://github.com/nodejs/LTS
sudo: false
language: node_js
os:
  - linux
node_js:
  - '12' # current release
  - '10' # active lts
  - '8' # maintenance lts
  - '6' # end of life
  - '4' # end of life
  - '0.12' # end of life
  - '0.10' # end of life
  - '0.8' # end of life
  - '0.6' # end of life
matrix:
  fast_finish: true
  allow_failures:
    - node_js: '6'
    - node_js: '4'
    - node_js: '0.12'
    - node_js: '0.10'
    - node_js: '0.8'
    - node_js: '0.6'
cache:
  directories:
    - $HOME/.npm # npm's cache
    - $HOME/.yarn-cache # yarn's cache
    - '$(nvm cache dir)' # nvm's cache
```

## Scripts

We provide many premade scripts to accelerate your Travis CI usage. They are available within the [`scripts` directory](https://github.com/bevry/awesome-travis/tree/master/scripts) directory of this repository. Click on each script to see available configuration, and installation instructions.

### Listing

#### [`deploy-custom`](https://github.com/bevry/awesome-travis/blob/master/scripts/deploy-custom.bash)

If the tests succeed on the specified `DEPLOY_BRANCH`, then prepare git for deployment, and then run the `DEPLOY_COMMAND`.

#### [`deploy-git`](https://github.com/bevry/awesome-travis/blob/master/scripts/deploy-git.bash)

If the tests succeed on the specified `DEPLOY_BRANCH`, then prepare git for deployment, and then run the `DEPLOY_COMMAND`.

#### [`deploy-now`](https://github.com/bevry/awesome-travis/blob/master/scripts/deploy-now.bash)

If the tests succeed on the specified `DEPLOY_BRANCH`, then deploy with https://zeit.co/now

#### [`node-install`](https://github.com/bevry/awesome-travis/blob/master/scripts/node-install.bash)

Use the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version) to install dependencies using `SETUP_COMMAND` (defaults to `npm install`).

This is an alternative to the `node-npm-install` script.

#### [`node-npm-install`](https://github.com/bevry/awesome-travis/blob/master/scripts/node-npm-install.bash)

Because the latest npm version that node 0.6 and 0.9 support, doesn't support scoped modules, so it uses node 0.8 to install npm packages and then switches back.

This is an alternative to the `node-install` script.

#### [`node-publish`](https://github.com/bevry/awesome-travis/blob/master/scripts/node-publish.bash)

Use the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version) to login with npm and run `npm publish`.

#### [`node-upgrade-npm`](https://github.com/bevry/awesome-travis/blob/master/scripts/node-upgrade-npm.bash)

Installs the latest supported version of npm for the current node version, using nvm's `install-latest-npm` command.

This is an alternative to the `node-latest-npm` script.

#### [`node-latest-npm`](https://github.com/bevry/awesome-travis/blob/master/scripts/node-latest-npm.bash)

Installs the latest npm version, using npm's `update` command.

This is an alternative to the `node-upgrade-npm` script.

#### [`node-verify`](https://github.com/bevry/awesome-travis/blob/master/scripts/node-verify.bash)

If our current node version is the `DESIRED_NODE_VERSION` (defaults to the latest LTS node version) then compile and lint our project with: `npm run our:compile && npm run our:verify` otherwise just compile our project with: `npm run our:compile`.

#### [`surge`](https://github.com/bevry/awesome-travis/blob/master/scripts/surge.bash)

If the tests succeeded, then deploy our release to [Surge](https://surge.sh) for our branch, tag, and commit.

#### [`travis-another`](https://github.com/bevry/awesome-travis/blob/master/scripts/travis-another.bash)

Trigger another travis projects tests after completion of the current travis project.

### Installation

When following the installation instructions for a script, you probably want to change `master` [to the the current commit hash](https://help.github.com/en/articles/getting-permanent-links-to-files#press-kbdykbd-to-permalink-to-a-file-in-a-specific-commit), for instance changing:

```yaml
- eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-install.bash)"
```

To:

```yaml
- eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/19a67716252376729cff23f63818c1c797bc3b63/scripts/node-install.bash)"
```

**Alternatively,** you could download the script to a new `.travis` folder inside your repository and use that instead:

```bash
mkdir -p ./.travis
wget https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-install.bash ./.travis/node-install.bash
chmod +x ./.travis/node-install.bash
```

```yaml
install:
  - ./.travis/node-install.bash
```

## Generators

- [`boundation`](https://github.com/bevry/boundation) generates your project, including your `.travis.yml` file, using this awesome list

## Contribution

Send pull requests for your scripts and config nifties! Will be awesome!

Although, avoid changing header titles and file names, as people may reference them when they use parts.

## License

Public Domain via The Unlicense
