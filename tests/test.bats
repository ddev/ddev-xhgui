setup() {
  set -eu -o pipefail
  brew_prefix=$(brew --prefix)
  load "${brew_prefix}/lib/bats-support/load.bash"
  load "${brew_prefix}/lib/bats-assert/load.bash"

  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export PROJNAME=test-ddev-xhgui
  export TESTDIR=~/tmp/${PROJNAME}
  mkdir -p $TESTDIR
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
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

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  ddev config --project-name=${PROJNAME}
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart

  # Check service works
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev config --project-name=${PROJNAME}
  echo "# ddev add-on get ddev/ddev-xhgui with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ddev/ddev-xhgui
  ddev restart

  # Check service works
  health_checks
}

@test "it can profile using the default (mariadb) database" {
  set -eu -o pipefail
  cd ${TESTDIR}

  # Create test site
  echo "# Create a demo website at ${TESTDIR}" >&3
  ddev config --docroot=public --create-docroot
  ddev composer require perftools/php-profiler
  ddev composer install
  echo "<?php
require_once __DIR__ . '/../vendor/autoload.php';
require_once '/mnt/ddev_config/xhgui/collector/xhgui.collector.php';
echo 'Demo website';" >${TESTDIR}/public/index.php

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart

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
  cd ${TESTDIR}

  # Create test site
  echo "# Create a demo website at ${TESTDIR} using MySQL" >&3
  ddev config --docroot=public --create-docroot --database=mysql:8.0
  ddev composer require perftools/php-profiler
  ddev composer install
  echo "<?php
require_once __DIR__ . '/../vendor/autoload.php';
require_once '/mnt/ddev_config/xhgui/collector/xhgui.collector.php';
echo 'Demo website';" >${TESTDIR}/public/index.php

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart

  # Check service works
  health_checks
  collector_checks

  # Check it removes database on uninstall. 'mysql "name"' returns 1 if db exists, 0 if missing.
  ddev mysql "xhgui" -e exit > /dev/null 2>&1 && echo "Database exists." | grep "exists"
  ddev add-on remove ${DIR}
  ddev mysql "xhgui" -e exit > /dev/null 2>&1 && echo "Database exists." || echo "Database missing" | grep "missing"
}

@test "it can profile using a Postres database" {
  set -eu -o pipefail
  cd ${TESTDIR}

  # Create test site
  echo "# Create a demo website at ${TESTDIR} using Postgres" >&3
  ddev config --docroot=public --create-docroot --database=postgres:16
  ddev composer require perftools/php-profiler
  ddev composer install
  echo "<?php
require_once __DIR__ . '/../vendor/autoload.php';
require_once '/mnt/ddev_config/xhgui/collector/xhgui.collector.php';
echo 'Demo website';" >${TESTDIR}/public/index.php

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart

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
  cd ${TESTDIR}
  ddev config --project-name=${PROJNAME} --router-http-port=8080 --router-https-port=8443
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart

  # Check service works
  health_checks
}
