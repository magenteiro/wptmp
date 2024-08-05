#!/bin/bash

# Sync Plugins
wp plugin list --field=name --allow-root > installed_plugins.txt
grep -oP '"name": "\K[^"]+' .github/workflows/plugins.json > plugins_to_sync.txt
while IFS= read -r plugin; do
  name=$(echo "$plugin" | awk -F'"' '{print $4}')
  status=$(grep -A 3 "\"name\": \"$name\"" .github/workflows/plugins.json | grep -oP '"status": "\K[^"]+')
  version=$(grep -A 3 "\"name\": \"$name\"" .github/workflows/plugins.json | grep -oP '"version": "\K[^"]+')
  if ! grep -q "$name" installed_plugins.txt; then
    wp plugin install "$name" --version="$version" --allow-root
  else
    wp plugin update "$name" --version="$version" --allow-root
  fi
  if [ "$status" = "active" ]; then
    wp plugin activate "$name" --allow-root
  else
    wp plugin deactivate "$name" --allow-root
  fi
done < plugins_to_sync.txt
for installed_plugin in $(cat installed_plugins.txt); do
  if ! grep -q "\"name\": \"$installed_plugin\"" .github/workflows/plugins.json; then
    wp plugin delete "$installed_plugin" --allow-root
  fi
done