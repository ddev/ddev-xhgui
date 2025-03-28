#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=ddev/ddev-xhgui

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"

  # This add-on is a part of DDEV since v1.24.4
  if [[ "$(ddev --version)" != "ddev version v1.24.3" ]]; then
    skip "This add-on is not intended to work with $(ddev --version)"
  fi

  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
}

health_checks() {
  set +u # bats-assert has unset variables so turn off unset check
  # Make sure we can hit the 8142 port successfully
  curl -s -I -f https://${PROJNAME}.ddev.site:8142 >/tmp/curlout.txt
  # Make sure `ddev xhgui` works
  DDEV_DEBUG=true run ddev xhgui
  assert_success
  assert_output --partial "FULLURL https://${PROJNAME}.ddev.site:8142"

  ddev exec "curl -s xhgui:80" | grep "XHGui - Run list"
}

# This tests the collector function works.
collector_checks() {
  # Turn on the collector
  ddev xhprof
  # Ensure there's no profiling data link
  ddev exec "curl -s xhgui:80" | grep -v '<a href="/?server_name=web">'

  # Profile site
  ddev exec "curl -s web:80" | grep "Demo website"
  sleep 5
  # Ensure there a profiling data link
  ddev exec "curl -s xhgui:80" | grep '<a href="/?server_name=web">'
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

@test "it can profile using the default (MariaDB) database" {
  set -eu -o pipefail
  cd ${TESTDIR}

  # Create test site
  echo "# Create a demo website at ${TESTDIR}" >&3
  ddev config --docroot=public
  ddev composer require perftools/php-profiler
  ddev composer install
  echo "<?php
require_once __DIR__ . '/../vendor/autoload.php';
require_once '/mnt/ddev_config/xhgui/collector/xhgui.collector.php';
echo 'Demo website';" >${TESTDIR}/public/index.php

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  # Check service works
  health_checks
  collector_checks

  # Check it removes database on uninstall. 'mysql "name"' returns 1 if db exists, 0 if missing.
  ddev mysql "xhgui" -e exit > /dev/null 2>&1 && echo "Database exists." | grep "exists"
  ddev add-on remove ${DIR}
  ddev mysql "xhgui" -e exit > /dev/null 2>&1 && echo "Database exists." || echo "Database missing" | grep "missing"
}

@test "it can profile using a MySQL database" {
  set -eu -o pipefail

  # Create test site
  echo "# Create a demo website at ${TESTDIR} using MySQL" >&3
  ddev config --docroot=public --database=mysql:8.0
  ddev composer require perftools/php-profiler
  ddev composer install
  echo "<?php
require_once __DIR__ . '/../vendor/autoload.php';
require_once '/mnt/ddev_config/xhgui/collector/xhgui.collector.php';
echo 'Demo website';" >${TESTDIR}/public/index.php

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  # Check service works
  health_checks
  collector_checks

  # Check it removes database on uninstall. 'mysql "name"' returns 1 if db exists, 0 if missing.
  ddev mysql "xhgui" -e exit > /dev/null 2>&1 && echo "Database exists." | grep "exists"
  ddev add-on remove ${DIR}
  ddev mysql "xhgui" -e exit > /dev/null 2>&1 && echo "Database exists." || echo "Database missing" | grep "missing"
}

@test "it can profile using a Postgres database" {
  set -eu -o pipefail

  # Create test site
  echo "# Create a demo website at ${TESTDIR} using Postgres" >&3
  ddev config --docroot=public --database=postgres:16
  ddev composer require perftools/php-profiler
  ddev composer install
  echo "<?php
require_once __DIR__ . '/../vendor/autoload.php';
require_once '/mnt/ddev_config/xhgui/collector/xhgui.collector.php';
echo 'Demo website';" >${TESTDIR}/public/index.php

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  # Check service works
  health_checks
  collector_checks

  # Check it removes database on uninstall. `psql "xhgui" -c '\q'` returns 1 if db exists, 0 if missing.
  ddev psql "xhgui" -c '\q' > /dev/null 2>&1 && echo "Database exists." | grep "exists"
  ddev add-on remove ${DIR}
  ddev psql "xhgui" -c '\q' > /dev/null 2>&1 && echo "Database exists." || echo "Database missing" | grep "missing"
}

@test "install from directory with nonstandard port" {
  set -eu -o pipefail
  ddev config --project-name=${PROJNAME} --router-http-port=8080 --router-https-port=8443

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  # Check service works
  health_checks
}
