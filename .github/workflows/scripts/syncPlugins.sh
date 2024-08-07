#!/bin/bash

# Set locale environment variables
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# List installed plugins with status
wp plugin list --fields=name,status --allow-root > installed_plugins.txt

# Extract names and statuses of plugins to be synchronized
grep -oP '"name": "\K[^"]+' .github/workflows/plugins.json > plugins_to_sync_names.txt
grep -oP '"status": "\K[^"]+' .github/workflows/plugins.json > plugins_to_sync_statuses.txt

# Combine names and statuses into a single file
paste -d, plugins_to_sync_names.txt plugins_to_sync_statuses.txt > plugins_to_sync.txt

# Debug: Print the content of plugins_to_sync.txt
echo "Plugins to sync:"
cat plugins_to_sync.txt

# Debug: Print the content of installed_plugins.txt
echo "Currently installed plugins:"
cat installed_plugins.txt

# Process each plugin to be synchronized
while IFS=, read -r name status; do
  # Debug: Print the current plugin name and status
  echo "Processing plugin: $name, Status: $status"

  # Check if the plugin is already installed with the same status
  if grep -q "$name,$status" installed_plugins.txt; then
    echo "Plugin $name is already installed with status $status. Skipping."
    continue
  fi

  if [ "$status" = "active" ]; then
    echo "Activating plugin: $name"
    wp plugin activate "$name" --allow-root
  else
    echo "Deactivating plugin: $name"
    wp plugin deactivate "$name" --allow-root
  fi
done < plugins_to_sync.txt