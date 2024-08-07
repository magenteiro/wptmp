#!/bin/bash

# Set locale environment variables
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# List installed themes with status
wp theme list --fields=name,status --allow-root | tr -s ' ' | cut -d ' ' -f1,2 > installed_themes.txt

# Extract names and statuses of themes to be synchronized
grep -oP '"name": "\K[^"]+' .github/workflows/themes.json > themes_to_sync_names.txt
grep -oP '"status": "\K[^"]+' .github/workflows/themes.json > themes_to_sync_statuses.txt

# Combine names and statuses into a single file
paste -d, themes_to_sync_names.txt themes_to_sync_statuses.txt > themes_to_sync.txt

# Debug: Print the content of themes_to_sync.txt
echo "Themes to sync:"
cat themes_to_sync.txt

# Debug: Print the content of installed_themes.txt
echo "Currently installed themes:"
cat installed_themes.txt

# Process each theme to be synchronized
while IFS=, read -r name status; do
# Debug: Print the current theme name and status
echo "Processing theme: $name, Status: $status"

# Check if the theme is already installed with the same status
if grep -Pq "$name\t+$status" installed_themes.txt; then
echo "Plugin $name is already installed with status $status. Skipping."
continue
fi

if [ "$status" = "active" ]; then
echo "Activating theme: $name"
wp theme activate "$name" --allow-root
else
echo "Deactivating theme: $name"
wp theme deactivate "$name" --allow-root
fi
done < themes_to_sync.txt

# Clean up temporary files
rm -f themes_to_sync_names.txt themes_to_sync_statuses.txt themes_to_sync.txt installed_themes.txt