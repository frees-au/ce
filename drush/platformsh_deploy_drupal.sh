#!/usr/bin/env bash
#
# We don't want to run drush commands if drupal isn't installed.
# Similarly, we don't want to attempt to run config-import if there aren't any config files to import
# @todo expand further to pass --uri for all sites, with an eye towards multisite
#


if [ -n "$(drush status --field=bootstrap)" ]; then
  drush deploy -y
else
  echo "Drupal not installed. Skipping standard Drupal deploy steps"
fi
