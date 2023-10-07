#!/bin/bash

# Usage:
# 1. To print the page generation time:
#    ./script_name.sh
#
# 2. To activate a specific number of inactive plugins (default is 1):
#    ./script_name.sh activate_plugin [batch_size]
#
# 3. To deactivate a specific number of active plugins (default is 1):
#    ./script_name.sh deactivate_plugin [batch_size]
#
# Replace 'your_username', 'your_password', and 'your_website_url' with actual WordPress credentials and website URL.
# Customize plugin names in EXCLUDED_PLUGINS array as needed.

# Customize: Add plugin names you want to exclude
EXCLUDED_PLUGINS=("plugin_name1" "plugin_name2")

# Customize: Replace 'your_username' and 'your_password' with the actual WordPress admin username and password
WP_USERNAME="your_username"
WP_PASSWORD="your_password"

# Customize: Default batch size for plugin activation/deactivation
BATCH_SIZE=${1:-1}

if [ "$BATCH_SIZE" -lt 1 ]; then
    echo "Batch size should be at least 1."
    exit 1
fi

if [ "$#" -eq 0 ]; then
    # Case when no parameter is provided, just print the page generation time
    echo "Opening the URL and printing Page Generation Time"
    # Customize: Replace 'your_website_url' with the actual WordPress website URL
    page_generation_time=$(curl -s -w "%{time_total}\n" -o /dev/null -u "$WP_USERNAME:$WP_PASSWORD" "https://your_website_url/")
    echo "Page Generation Time: ${page_generation_time}s"
    exit 0
fi

if [ "$1" == "activate_plugin" ]; then
    # Activate the first inactive plugin excluding excluded plugins
    plugin_names=($(wp plugin list --status=inactive --field=name --format=csv | grep -Ev "$(IFS=\|; echo "${EXCLUDED_PLUGINS[*]}")"))
    num_plugins=${#plugin_names[@]}
    
    if [ "$num_plugins" -eq 0 ]; then
        echo "No inactive plugins to activate."
        exit 0
    fi
    
    for ((i = 0; i < BATCH_SIZE && i < num_plugins; i++)); do
        plugin_name="${plugin_names[$i]}"
        echo "Activating plugin: $plugin_name"
        wp plugin activate "$plugin_name" --quiet
    done
elif [ "$1" == "deactivate_plugin" ]; then
    # Deactivate the last active plugin excluding excluded plugins
    plugin_names=($(wp plugin list --status=active --field=name --format=csv | grep -Ev "$(IFS=\|; echo "${EXCLUDED_PLUGINS[*]}")"))
    num_plugins=${#plugin_names[@]}
    
    if [ "$num_plugins" -eq 0 ]; then
        echo "No active plugins to deactivate."
        exit 0
    fi
    
    for ((i = num_plugins - 1; i >= num_plugins - BATCH_SIZE && i >= 0; i--)); do
        plugin_name="${plugin_names[$i]}"
        echo "Deactivating plugin: $plugin_name"
        wp plugin deactivate "$plugin_name" --quiet
    done
fi

# Print the page generation time
echo "Opening the URL and printing Page Generation Time"
# Customize: Replace 'your_website_url' with the actual WordPress website URL
page_generation_time=$(curl -s -w "%{time_total}\n" -o /dev/null -u "$WP_USERNAME:$WP_PASSWORD" "https://your_website_url/")
echo "Page Generation Time: ${page_generation_time}s"
