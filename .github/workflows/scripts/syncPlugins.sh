#!/bin/bash

# Set locale environment variables
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# List installed plugins with version
wp plugin list --fields=name,version --allow-root > installed_plugins.txt

# Extract names and versions of plugins to be synchronized
grep -oP '"name": "\K[^"]+' .github/workflows/plugins.json > plugins_to_sync.txt
grep -oP '"version": "\K[^"]+' .github/workflows/plugins.json >> plugins_to_sync.txt

# Debug: Print the content of plugins_to_sync.txt
echo "Plugins to sync:"
cat plugins_to_sync.txt

# Debug: Print the content of installed_plugins.txt
echo "Currently installed plugins:"
cat installed_plugins.txt

# Process each plugin to be synchronized
while IFS= read -r name; do
  # Read the version from the next line
  read -r version

  # Debug: Print the current plugin name and version
  echo "Processing plugin: $name, Version: $version"

  # Check if the plugin is already installed with the same version
  if grep -q "$name,$version" installed_plugins.txt; then
    echo "Plugin $name is already installed with version $version. Skipping."
    continue
  fi

  status=$(grep -A 3 "\"name\": \"$name\"" .github/workflows/plugins.json | grep -oP '"status": "\K[^"]+')

  # Debug: Print the status
  echo "Status: $status"

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

for installed_plugin in $(cut -d, -f1 installed_plugins.txt); do
  if ! grep -q "\"name\": \"$installed_plugin\"" .github/workflows/plugins.json; then
    echo "Deleting plugin: $installed_plugin"
    wp plugin delete "$installed_plugin" --allow-root
  fi
done