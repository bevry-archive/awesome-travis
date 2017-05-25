# awesome-travis

Crowd-sourced list of [Travis CI](https://travis-ci.org) hooks/scripts etc to level up your `.travis.yml` file


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


## Scripts

Find scripts you can use, including their inline documentaiton, inside the [`scripts` directory](https://github.com/balupton/awesome-travis/tree/master/scripts).

### Tips

The scripts in this repository are their own files, which the latest are fetched. E.g.

``` yaml
install:
  - eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/node-install.bash)"
```

You probably want to change the `master` to the the current commit hash. For instance:

``` yaml
install:
  - eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/some-commit-hash-instead/scripts/node-install.bash)"
```

Or you could even download it into a `.travis` folder for local use instead:

``` bash
mkdir -p ./.travis
wget https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/node-install.bash ./.travis/node-install.bash
chmod +x ./.travis/node-install.bash
```

``` yaml
install:
  - ./.travis/node-install.bash
```


## Legacy 

Older script instructions are here:

### Rerun another project's tests

Useful for when you have a content repository that is used by a different repository, and as such, when the content repository changes, you want to rerun the tests for the other repository, perhaps even for deployment purposes.

Create your `GITHUB_TRAVIS_TOKEN` by creating a [GitHub Personal Access Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) with the `repo` permission.

``` bash
# configuration commands
travis env set GITHUB_TRAVIS_TOKEN "$GITHUB_TRAVIS_TOKEN"
travis env set OTHER_REPO_SLUG "bevry/staticsitegenerators-website" --public
```

``` yaml
# travis configuration
sudo: false
language: ruby
rvm:
  - "2.2"
install:
  - gem install travis --no-rdoc --no-ri
script:
  - eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/travis-another.bash)"
```

Used by [bevry/staticsitegenerators-list](https://github.com/bevry/staticsitegenerators-list)



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
  - eval "$(curl -s https://raw.githubusercontent.com/balupton/awesome-travis/master/scripts/surge.bash)"
```

Used by [bevry/base](https://github.com/bevry/base) with example at [bevry/badges](https://github.com/bevry/badges)



## Contribution

Send pull requests for your scripts and config nifties! Will be awesome!

Although, avoid changing header titles and file names, as people may reference them when they use parts.


## License

Public Domain via The Unlicense
