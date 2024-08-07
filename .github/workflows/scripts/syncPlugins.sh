#!/bin/bash

# Set locale environment variables
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# List installed plugins with version and status
wp plugin list --fields=name,version,status --allow-root > installed_plugins.txt

# Extract names, versions, and statuses of plugins to be synchronized
grep -oP '"name": "\K[^"]+' .github/workflows/plugins.json > plugins_to_sync_names.txt
grep -oP '"version": "\K[^"]+' .github/workflows/plugins.json > plugins_to_sync_versions.txt
grep -oP '"status": "\K[^"]+' .github/workflows/plugins.json > plugins_to_sync_statuses.txt

# Combine names, versions, and statuses into a single file
paste -d, plugins_to_sync_names.txt plugins_to_sync_versions.txt plugins_to_sync_statuses.txt > plugins_to_sync.txt

# Debug: Print the content of plugins_to_sync.txt
echo "Plugins to sync:"
cat plugins_to_sync.txt

# Debug: Print the content of installed_plugins.txt
echo "Currently installed plugins:"
cat installed_plugins.txt

# Process each plugin to be synchronized
while IFS=, read -r name version status; do
  # Debug: Print the current plugin name, version, and status
  echo "Processing plugin: $name, Version: $version, Status: $status"

  # Check if the plugin is already installed with the same version and status
  if grep -q "$name,$version,$status" installed_plugins.txt; then
    echo "Plugin $name is already installed with version $version and status $status. Skipping."
    continue
  fi

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

# Remove plugins not listed in the JSON
while IFS=, read -r installed_name installed_version installed_status; do
  if ! grep -q "\"name\": \"$installed_name\"" .github/workflows/plugins.json; then
    echo "Deleting plugin: $installed_name"
    wp plugin delete "$installed_name" --allow-root
  fi
done < installed_plugins.txt