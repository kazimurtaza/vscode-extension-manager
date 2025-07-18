#!/bin/bash

# Usage: manage_extensions.sh [URL]
# If URL is provided, it will extract extension details, add to YAML, and install
# URL format: https://open-vsx.org/api/publisher/name/version/file/publisher.name-version.vsix

# --- Configuration ---
CODE_SERVER_PATH="/usr/lib/code-server/lib/vscode/bin/remote-cli/code-server"
EXTENSIONS_DIR="/root/.local/share/code-server/extensions"
TEMP_DIR="/tmp/code-server-ext-updates"
YAML_FILES_PATTERN="*.yaml" # Pattern to find your YAML files (e.g., extensions.yaml)

# --- Functions ---

# Function to parse extension details from Open VSX URL
parse_extension_url() {
    local url="$1"
    # Extract publisher, name, and version from URL
    # Format: https://open-vsx.org/api/publisher/name/version/file/publisher.name-version.vsix
    if [[ "$url" =~ https://open-vsx\.org/api/([^/]+)/([^/]+)/([^/]+)/file/([^/]+) ]]; then
        local publisher="${BASH_REMATCH[1]}"
        local name="${BASH_REMATCH[2]}"
        local version="${BASH_REMATCH[3]}"
        local ext_id="${publisher}.${name}"
        
        echo "$ext_id $version $url"
        return 0
    else
        echo "Error: Invalid Open VSX URL format" >&2
        echo "Expected format: https://open-vsx.org/api/publisher/name/version/file/publisher.name-version.vsix" >&2
        return 1
    fi
}

# Function to add extension to YAML file
add_extension_to_yaml() {
    local ext_id="$1"
    local version="$2"
    local yaml_file="extensions.yaml"
    
    if [ ! -f "$yaml_file" ]; then
        echo "extensions:" > "$yaml_file"
    fi
    
    # Check if extension already exists in YAML
    if yq ".extensions[] | select(.id == \"$ext_id\")" "$yaml_file" | grep -q "id:"; then
        echo "Extension $ext_id already exists in $yaml_file. Updating version to $version..."
        yq -i "(.extensions[] | select(.id == \"$ext_id\") | .version) = \"$version\"" "$yaml_file"
    else
        echo "Adding extension $ext_id version $version to $yaml_file..."
        yq -i ".extensions += [{\"id\": \"$ext_id\", \"version\": \"$version\"}]" "$yaml_file"
    fi
}

# Function to install extension from URL
install_from_url() {
    local url="$1"
    local ext_id="$2"
    local version="$3"
    
    local filename=$(basename "$url")
    local output_path="${TEMP_DIR}/${filename}"
    
    echo "Downloading extension from: $url"
    curl -L -f -o "$output_path" "$url"
    
    if [ $? -eq 0 ] && [ -s "$output_path" ] && file "$output_path" | grep -q "Zip archive data"; then
        echo "Downloaded: $output_path"
        install_extension "$output_path"
        return $?
    else
        echo "Failed to download extension from: $url" >&2
        rm -f "$output_path"
        return 1
    fi
}

# Function to get latest version from Open VSX (using REST API)
get_latest_openvsx_version() {
    local ext_id="$1" # e.g., bradlc.vscode-tailwindcss
    local publisher=$(echo "$ext_id" | cut -d'.' -f1)
    local name=$(echo "$ext_id" | cut -d'.' -f2-)

    echo "Querying Open VSX API for latest version of ${ext_id}..." >&2
    # Use Open VSX REST API to get extension information
    local api_response=$(curl -s "https://open-vsx.org/api/$publisher/$name")
    
    if [ $? -eq 0 ] && [ -n "$api_response" ]; then
        # Parse JSON response to get version - prefer jq if available, fallback to grep
        local latest_version
        if command -v jq &> /dev/null; then
            latest_version=$(echo "$api_response" | jq -r '.version // empty' 2>/dev/null)
        else
            latest_version=$(echo "$api_response" | grep -o '"version":"[^"]*' | cut -d'"' -f4 | head -n 1)
        fi
        
        if [ -n "$latest_version" ] && [ "$latest_version" != "null" ]; then
            echo "$latest_version"
            return 0
        fi
    fi
    
    echo "Error: Could not fetch latest version for ${ext_id} from Open VSX API" >&2
    return 1
}

# Function to download .vsix from Open VSX (can be unreliable)
download_vsix() {
    local ext_id="$1"
    local version="$2"
    local publisher=$(echo "$ext_id" | cut -d'.' -f1)
    local name=$(echo "$ext_id" | cut -d'.' -f2-)
    local vsix_filename="${publisher}.${name}-${version}.vsix"
    # Using the resourceUrlTemplate which has shown some success
    local download_url="https://openvsxorg.blob.core.windows.net/resources/${publisher}/${name}/${version}/${vsix_filename}"
    local output_path="${TEMP_DIR}/${vsix_filename}"

    echo "Attempting to download ${ext_id}@${version} from ${download_url}"
    # Use -L to follow redirects, -f to fail silently on HTTP errors, -o for output file
    curl -L -f -o "$output_path" "$download_url"

    if [ $? -eq 0 ] && [ -s "$output_path" ] && file "$output_path" | grep -q "Zip archive data"; then
        echo "Downloaded: $output_path"
        echo "$output_path"
    else
        echo "Failed to download ${ext_id}@${version}. The URL might be incorrect, the file is not directly served, or it's not a valid VSIX." >&2
        rm -f "$output_path" # Clean up potentially invalid download
        return 1
    fi
}

# Function to install extension from a .vsix file
install_extension() {
    local vsix_path="$1"
    echo "Installing extension from: $vsix_path"
    "$CODE_SERVER_PATH" --install-extension "$vsix_path" --force
    if [ $? -eq 0 ]; then
        echo "Successfully installed: $vsix_path"
    else
        echo "Failed to install: $vsix_path" >&2
        return 1
    fi
}

# Function to uninstall extension by ID
uninstall_extension() {
    local ext_id="$1"
    echo "Uninstalling extension: $ext_id"
    "$CODE_SERVER_PATH" --uninstall-extension "$ext_id"
    if [ $? -eq 0 ]; then
        echo "Successfully uninstalled: $ext_id"
    else
        echo "Failed to uninstall: $ext_id" >&2
        return 1
    fi
}

# --- Main Script Logic ---

# Create temporary directory for downloads
mkdir -p "$TEMP_DIR" || { echo "Failed to create temp directory: $TEMP_DIR"; exit 1; }

# Check if URL argument is provided
if [ $# -eq 1 ]; then
    url_arg="$1"
    
    # Handle help requests
    if [[ "$url_arg" == "--help" || "$url_arg" == "-h" ]]; then
        echo "Usage: $0 [URL]"
        echo ""
        echo "  Without arguments: Process all extensions from YAML files"
        echo "  With URL argument: Extract extension details from URL, add to YAML, and install"
        echo ""
        echo "URL format: https://open-vsx.org/api/publisher/name/version/file/publisher.name-version.vsix"
        echo ""
        echo "Examples:"
        echo "  $0"
        echo "  $0 https://open-vsx.org/api/Anthropic/claude-code/1.0.29/file/Anthropic.claude-code-1.0.29.vsix"
        exit 0
    fi
    
    echo "URL mode: Processing extension from URL: $url_arg"
    
    # Parse the URL to extract extension details
    url_info=$(parse_extension_url "$url_arg")
    if [ $? -ne 0 ]; then
        echo "Failed to parse URL. Exiting."
        exit 1
    fi
    
    # Extract components
    ext_id=$(echo "$url_info" | awk '{print $1}')
    version=$(echo "$url_info" | awk '{print $2}')
    url=$(echo "$url_info" | awk '{print $3}')
    
    echo "Parsed extension: $ext_id version $version"
    
    # Add to YAML file
    add_extension_to_yaml "$ext_id" "$version"
    
    # Install from URL
    install_from_url "$url" "$ext_id" "$version"
    
    echo "Extension management complete."
    rm -rf "$TEMP_DIR"
    exit 0
fi

# 1. Get desired extensions from YAML files
declare -A desired_extensions # Associative array: ext_id -> version (if specified in YAML)
echo "Reading desired extensions from YAML files matching: $YAML_FILES_PATTERN"
for yaml_file in $YAML_FILES_PATTERN; do
    if [ -f "$yaml_file" ]; then
        echo "Processing $yaml_file..."
        # Requires 'yq' to be installed for robust YAML parsing
        if command -v yq &> /dev/null; then
            while read -r line; do
                ext_id=$(echo "$line" | awk '{print $1}')
                ext_version=$(echo "$line" | awk '{print $2}')
                desired_extensions["$ext_id"]="$ext_version"
            done < <(yq '.extensions[] | .id + " " + (.version // "latest")' "$yaml_file")
        else
            echo "Error: 'yq' command not found. Please install 'yq' for reliable YAML parsing." >&2
            echo "Skipping YAML file: $yaml_file" >&2
        fi
    fi
done

if [ ${#desired_extensions[@]} -eq 0 ]; then
    echo "No desired extensions found in YAML files. Exiting."
    exit 0
fi

# 2. Get currently installed extensions
declare -A installed_extensions # Associative array: ext_id -> version
echo "Scanning installed extensions in: $EXTENSIONS_DIR"
for ext_dir in "$EXTENSIONS_DIR"/*; do
    if [ -d "$ext_dir" ]; then
        dir_name=$(basename "$ext_dir")
        # Extract publisher.name and version from directory name (e.g., publisher.extension-1.2.3)
        # This regex is simplified and might need adjustment for complex names or non-standard versions
        if [[ "$dir_name" =~ ^([a-zA-Z0-9-]+)\.([a-zA-Z0-9-]+)-([0-9]+\.[0-9]+\.[0-9]+.*)$ ]]; then
            publisher="${BASH_REMATCH[1]}"
            name="${BASH_REMATCH[2]}"
            version="${BASH_REMATCH[3]}"
            ext_id="${publisher}.${name}"
            installed_extensions["$ext_id"]="$version"
        elif [[ "$dir_name" =~ ^([a-zA-Z0-9-]+)\.([a-zA-Z0-9-]+)$ ]]; then
            # Handle extensions without explicit version in directory name (less common for .vsix installs)
            publisher="${BASH_REMATCH[1]}"
            name="${BASH_REMATCH[2]}"
            ext_id="${publisher}.${name}"
            installed_extensions["$ext_id"]="unknown" # Mark as unknown version
        else
            echo "Warning: Could not parse extension directory name: $dir_name. Skipping." >&2
        fi
    fi
done

# 3. Compare and Act (Update/Install)
echo "Checking for updates and new installations..."
for desired_ext_id in "${!desired_extensions[@]}"; do
    desired_version="${desired_extensions[$desired_ext_id]}"
    installed_version="${installed_extensions[$desired_ext_id]}"

    if [ -z "$installed_version" ]; then
        echo "Extension ${desired_ext_id} is desired but not installed. Installing..."
        target_version="$desired_version"
        if [ "$desired_version" == "latest" ]; then
            target_version=$(get_latest_openvsx_version "$desired_ext_id")
            if [ -z "$target_version" ]; then
                echo "Error: Could not determine latest version for ${desired_ext_id}. Skipping installation." >&2
                continue
            fi
        fi
        vsix_file=$(download_vsix "$desired_ext_id" "$target_version")
        if [ $? -eq 0 ]; then
            install_extension "$vsix_file"
        fi
    elif [ "$installed_version" != "$desired_version" ] && [ "$desired_version" != "latest" ]; then
        # If a specific version is desired and it's different from installed
        echo "Extension ${desired_ext_id} installed version ${installed_version} is different from desired ${desired_version}. Updating..."
        vsix_file=$(download_vsix "$desired_ext_id" "$desired_version")
        if [ $? -eq 0 ]; then
            install_extension "$vsix_file"
        fi
    elif [ "$desired_version" == "latest" ]; then
        # If "latest" is desired, check against actual latest
        latest_version=$(get_latest_openvsx_version "$desired_ext_id")
        if [ -z "$latest_version" ]; then
            echo "Error: Could not determine latest version for ${desired_ext_id}. Skipping update check." >&2
            continue
        fi
        # Simple string comparison for versions. For robust comparison, use a dedicated tool.
        if [[ "$(printf '%s\n' "$installed_version" "$latest_version" | sort -V | head -n 1)" != "$latest_version" ]]; then
            echo "Extension ${desired_ext_id} installed version ${installed_version} is outdated (latest: ${latest_version}). Updating..."
            vsix_file=$(download_vsix "$desired_ext_id" "$latest_version")
            if [ $? -eq 0 ]; then
                install_extension "$vsix_file"
            fi
        else
            echo "Extension ${desired_ext_id} is up to date (${installed_version})."
        fi
    else
        echo "Extension ${desired_ext_id} is up to date and matches desired version (${installed_version})."
    fi
done

# 4. Compare and Act (Remove)
echo "Checking for extensions to remove..."
for installed_ext_id in "${!installed_extensions[@]}"; do
    if [ -z "${desired_extensions[$installed_ext_id]}" ]; then
        echo "Extension ${installed_ext_id} is installed but not in the desired list. Uninstalling..."
        uninstall_extension "$installed_ext_id"
    fi
done

echo "Extension management complete."
rm -rf "$TEMP_DIR" # Clean up temporary files
