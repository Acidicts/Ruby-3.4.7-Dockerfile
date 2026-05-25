# Ruby-3.4.7-Dockerfile

Ruby 3.4.7 (Debian Bookworm) base image with Rails/Bundler preinstalled, plus RVM for switching Ruby versions inside the container.

## Build

```bash
docker build -t ruby-3.4.7-rvm .
```

## Verify

```bash
docker run --rm ruby-3.4.7-rvm bash -lc "ruby --version && rails --version && bundler --version && rvm --version"
```

## Using RVM

Open a shell and install/use other Ruby versions with RVM:

```bash
docker run --rm -it ruby-3.4.7-rvm bash
rvm list known
rvm install 3.3.4
rvm use 3.3.4
ruby --version
```

Note: the upstream `ruby` image sets `GEM_HOME=/usr/local/bundle`. If you hit RVM/Gem path issues after switching Rubies, try:

```bash
unset GEM_HOME GEM_PATH
source /etc/profile.d/rvm.sh
```
