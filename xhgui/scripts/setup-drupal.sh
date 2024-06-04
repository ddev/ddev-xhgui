#!/usr/bin/env bash
#ddev-generated
set -e

# Early return if NOT Drupal project.
if [[ $DDEV_PROJECT_TYPE != drupal* ]] || [[ $DDEV_PROJECT_TYPE =~ ^drupal(6|7)$ ]] ; then
  exit 0
fi

# Earlt return if disable_settings_management is true.
if ( ddev debug configyaml 2>/dev/null | grep 'disable_settings_management:\s*true' >/dev/null 2>&1 ) ; then
  exit 0
fi

# Add perftools/php-profiler
if ( ddev composer show --all | grep -v perftools/php-profiler >/dev/null 2>&1 ) ; then
  ddev composer require perftools/php-profiler --dev
fi

# Copy over settings
XHGUI_SETTINGS=settings.ddev.xhgui.php
cp xhgui/scripts/$XHGUI_SETTINGS $DDEV_APPROOT/$DDEV_DOCROOT/sites/default/

# Add settings
SETTINGS_FILE_NAME="${DDEV_APPROOT}/${DDEV_DOCROOT}/sites/default/settings.php"
echo "Settings file name: ${SETTINGS_FILE_NAME}"
grep -qF $XHGUI_SETTINGS $SETTINGS_FILE_NAME || echo "
// Include settings required for XHGUI.
if ((file_exists(__DIR__ . '/$XHGUI_SETTINGS') && getenv('IS_DDEV_PROJECT') == 'true')) {
  include __DIR__ . '/$XHGUI_SETTINGS';
}" >> $SETTINGS_FILE_NAME
