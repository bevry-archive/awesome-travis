# awesome-travis

Crowd-sourced list of [Travis CI](https://travis-ci.org) hooks/scripts etc to level up your `.travis.yml` file


## Notifications

### Slack

``` bash
travis encrypt "$SLACK_SUBDOMAIN:$SLACK_TRAVIS_TOKEN#updates" --add notifications.slack
```


### Email

``` bash
travis encrypt "$TRAVIS_NOTIFICATION_EMAIL" --add notifications.email.recipients
```


## Node.js

### Complete Node.js Version Matrix

Complete configuration for the different [node.js versions](https://github.com/nodejs/LTS) one may need to support. With legacy versions allowed to fail.

``` yaml
# https://github.com/bevry/awesome-travis
# https://github.com/nodejs/LTS
sudo: false
language: node_js
os:
 - linux
before_install:
  - 'case "${TRAVIS_NODE_VERSION}" in 0.*) export NPM_CONFIG_STRICT_SSL=false ;; esac'
  - 'nvm install-latest-npm'
install:
  - 'if [ "${TRAVIS_NODE_VERSION}" = "0.6" ] || [ "${TRAVIS_NODE_VERSION}" = "0.9" ]; then nvm install --latest-npm 0.8 && npm install && nvm use "${TRAVIS_NODE_VERSION}"; else npm install; fi;'
node_js:
  - "11"    # current
  - "10"    # active lts
  - "8"     # active lts
  - "6"     # active lts
  - "4"     # end of life lts
  - "0.12"  # end of life
  - "0.10"  # end of life
  - "0.8"   # end of life
  - "0.6"   # end of life
matrix:
  fast_finish: true
  allow_failures:
    - node_js: "0.12"
    - node_js: "0.10"
    - node_js: "0.8"
    - node_js: "0.6"
cache:
  directories:
    - $HOME/.npm  # npm's cache
    - $HOME/.yarn-cache  # yarn's cache
    - "$(nvm cache dir)" # nvm's cache
```


## Scripts

The [`scripts` directory](https://github.com/bevry/awesome-travis/tree/master/scripts) contains scripts you can use.


### Tips

The scripts in this repository are their own files, which the latest are fetched. E.g.

``` yaml
install:
  - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-install.bash)"
```

You probably want to change the `master` to the the current commit hash. For instance:

``` yaml
install:
  - eval "$(curl -fsSL https://raw.githubusercontent.com/bevry/awesome-travis/some-commit-hash-instead/scripts/node-install.bash)"
```

Or you could even download it into a `.travis` folder for local use instead:

``` bash
mkdir -p ./.travis
wget https://raw.githubusercontent.com/bevry/awesome-travis/master/scripts/node-install.bash ./.travis/node-install.bash
chmod +x ./.travis/node-install.bash
```

``` yaml
install:
  - ./.travis/node-install.bash
```

## Generators

- [`bevry/based`](https://github.com/bevry/based) generates your project, including your `.travis.yml` file, using this awesome list


## Contribution

Send pull requests for your scripts and config nifties! Will be awesome!

Although, avoid changing header titles and file names, as people may reference them when they use parts.


## License

Public Domain via The Unlicense
