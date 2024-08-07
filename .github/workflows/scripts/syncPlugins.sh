#!/bin/bash

# Set locale environment variables
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Sync Plugins
wp plugin list --field=name --allow-root > installed_plugins.txt
grep -oP '"name": "\K[^"]+' .github/workflows/plugins.json > plugins_to_sync.txt

# Debug: Print the content of plugins_to_sync.txt
echo "Plugins to sync:"
cat plugins_to_sync.txt

# Debug: Print the content of installed_plugins.txt
echo "Currently installed plugins:"
cat installed_plugins.txt


while IFS= read -r name; do
  # Debug: Print the current plugin name
  echo "Processing plugin: $name"
  
  status=$(grep -A 3 "\"name\": \"$name\"" .github/workflows/plugins.json | grep -oP '"status": "\K[^"]+')
  version=$(grep -A 3 "\"name\": \"$name\"" .github/workflows/plugins.json | grep -oP '"version": "\K[^"]+')
  
  # Debug: Print the status and version
  echo "Status: $status, Version: $version"
  
  if ! grep -q "$name" installed_plugins.txt; then
    echo "Installing plugin: $name"
    wp plugin install "$name" --version="$version" --allow-root
  else
    echo "Updating plugin: $name"
    wp plugin update "$name" --version="$version" --allow-root
  fi
  if [ "$status" = "active" ]; then
    echo "Activating plugin: $name"
    wp plugin activate "$name" --allow-root
  else
    echo "Deactivating plugin: $name"
    wp plugin deactivate "$name" --allow-root
  fi
done < plugins_to_sync.txt

for installed_plugin in $(cat installed_plugins.txt); do
  if ! grep -q "\"name\": \"$installed_plugin\"" .github/workflows/plugins.json; then
    echo "Deleting plugin: $installed_plugin"
    wp plugin delete "$installed_plugin" --allow-root
  fi
done