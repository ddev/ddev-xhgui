setup() {
  set -eu -o pipefail

  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/ddev-xhgui
  mkdir -p $TESTDIR
  export PROJNAME=ddev-xhgui
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y
  echo "# ddev started at $(date)" >&3
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

health_checks() {
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
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ddev/ddev-mongo
  ddev get ${DIR}
  ddev restart

  # Check service works
  health_checks
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get tyler36/ddev-xhgui with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ddev/ddev-mongo
  ddev get tyler36/ddev-xhgui
  ddev restart

  # Check service works
  health_checks
}

@test "a site can be profiled" {
  set -eu -o pipefail
  cd ${TESTDIR}

  # Create test site
  echo "# Create a demo website at ${TESTDIR}" >&3
  ddev composer require perftools/php-profiler
  ddev composer install
  ddev config --docroot=public --create-docroot
  echo "<?php
require_once __DIR__ . '/../vendor/autoload.php';
require_once '/mnt/ddev_config/xhgui/collector/xhgui.collector.php';
echo 'Demo website';" >${TESTDIR}/public/index.php

  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ddev/ddev-mongo
  ddev get ${DIR}
  ddev restart

  # Check service works
  health_checks
  collector_checks
}
