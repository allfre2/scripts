#!/usr/bin/env bash

# Path to your configuration file (defaults to config.json in the current directory)
CONFIG_FILE="${CONFIG_FILE:-config.json}"

# Helper function to read values from the config JSON using jq
get_json_val() {
    jq -r "$1" "$CONFIG_FILE"
}

install_github_keys() {
    echo "Configuring ssh keys ..."

    # Start ssh-agent if not already running
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" > /dev/null
    fi

    local key_name="id_ed25519"
    local key_title="$(hostname)-$(date +%s)"
    local ssh_dir="$HOME/.ssh"

    local key_file="$ssh_dir/$key_name"

    # Remove existing key from ssh-agent and ~/.ssh to prevent overwrite prompts
    if [ -f "$key_file.pub" ]; then
        ssh-add -d "$key_file" 2>/dev/null || true
        rm -f "$key_file.pub"
    fi

    if [ -f "$key_file" ]; then
        rm -f "$key_file"
    fi

    # Generate new ed25519 ssh key without passphrase
    ssh-keygen -q -t ed25519 -f "$key_file" -N ""

    local token api_version keys_url
    token=$(get_json_val '.Git.Token')
    api_version=$(get_json_val '.Git.ApiVersion')
    keys_url=$(get_json_val '.Git.KeysUrl')

    local public_key
    public_key=$(cat "$key_file.pub")

    # Construct JSON payload and post to GitHub API
    local payload
    payload=$(jq -n --arg title "$key_title" --arg key "$public_key" '{title: $title, key: $key}')

    curl -s -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $token" \
        -H "X-GitHub-Api-Version: $api_version" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$keys_url" > /dev/null

    sleep 2

    ssh-add "$key_file"
    ssh-add -l

    echo "Verifying ssh connection ..."
    ssh -T git@github.com || true
}

set_git() {
    local source_dir user_name email repos_url token api_version
    source_dir="$HOME/$(get_json_val '.Git.SourceDir')"
    user_name=$(get_json_val '.Git.UserName')
    email=$(get_json_val '.Git.Email')
    repos_url=$(get_json_val '.Git.ReposUrl')
    token=$(get_json_val '.Git.Token')
    api_version=$(get_json_val '.Git.ApiVersion')

    echo "Creating source directory ..."

    # Resolve home directory or absolute paths
    if [[ "$source_dir" == ~* ]]; then
        eval source_dir="$source_dir"
    elif [[ "$source_dir" != /* ]]; then
        source_dir="$HOME/$source_dir"
    fi

    mkdir -p "$source_dir"

    echo "Configuring git ..."
    git config --global user.name "$user_name"
    git config --global user.email "$email"
    git config --global gpg.format ssh
    git config --global user.signingkey "$HOME/.ssh/id_ed25519.pub"
    git config --global commit.gpgsign true

    echo "Cloning repositories ..."

    local response
    response=$(curl -s -X GET \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $token" \
        -H "X-GitHub-Api-Version: $api_version" \
        "$repos_url")

    pushd "$source_dir" || exit 1

    # Iterate over repository SSH URLs and clone them
    echo "$response" | jq -r '.[] | .ssh_url' | while read -r ssh_url; do
        if [ -n "$ssh_url" ] && [ "$ssh_url" != "null" ]; then
            if [ ! -d "$(basename "$ssh_url" .git)" ]; then
                git clone "$ssh_url"
                # echo "$ssh_url"
            fi
        fi
    done

    popd

    echo "Repositories cloned successfully. Source directory: $source_dir"
}

initialize_git() {
    install_github_keys
    set_git
}