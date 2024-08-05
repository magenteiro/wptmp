#!/bin/bash

# Sync Themes
wp theme list --field=name --allow-root > installed_themes.txt
grep -oP '"name": "\K[^"]+' .github/workflows/themes.json > themes_to_sync.txt

# Debug: Print the content of themes_to_sync.txt
echo "Themes to sync:"
cat themes_to_sync.txt

while IFS= read -r name; do
  # Debug: Print the current theme name
  echo "Processing theme: $name"
  
  status=$(grep -A 3 "\"name\": \"$name\"" .github/workflows/themes.json | grep -oP '"status": "\K[^"]+')
  version=$(grep -A 3 "\"name\": \"$name\"" .github/workflows/themes.json | grep -oP '"version": "\K[^"]+')
  update_version=$(grep -A 3 "\"name\": \"$name\"" .github/workflows/themes.json | grep -oP '"update_version": "\K[^"]+')
  
  # Debug: Print the status, version, and update_version
  echo "Status: $status, Version: $version, Update Version: $update_version"
  
  if ! grep -q "$name" installed_themes.txt; then
    wp theme install "$name" --version="$version" --allow-root
  else
    wp theme update "$name" --version="$update_version" --allow-root
  fi
  if [ "$status" = "active" ]; then
    wp theme activate "$name" --allow-root
  fi
done < themes_to_sync.txt

for installed_theme in $(cat installed_themes.txt); do
  if ! grep -q "\"name\": \"$installed_theme\"" .github/workflows/themes.json; then
    wp theme delete "$installed_theme" --allow-root
  fi
done