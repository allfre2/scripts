#!/bin/bash

source "./tools/git.sh"
source "./tools/tools.sh"

# Initialize variables with default values
APPS_FLAG=false
GIT_FLAG=false

# Loop through all arguments passed to the script
while [[ $# -gt 0 ]]; do
    case "$1" in
        --apps)
            APPS_FLAG=true
            shift # Move to the next argument
            ;;
        --git)
            GIT_FLAG=true
            shift 
            ;;
        -h|--help)
            echo "Usage: $0 [--apps] [--git]"
            exit 0
            ;;
    esac
done

if [ "$APPS_FLAG" = "true" ]; then
    install_tools
fi

if [ "$GIT_FLAG" = "true" ]; then
    initialize_git
fi
