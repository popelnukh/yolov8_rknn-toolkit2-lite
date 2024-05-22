#!/bin/bash

set -x

# Global variables
REPO_URL="https://github.com/airockchip/rknn-toolkit2.git"
REPO_NAME="$(basename ${REPO_URL%.*})"

# Find or download the repository
find_or_clone_repo() {
    # Try to find existing repository directory
    local repo_found=$(find / -type d -name "$REPO_NAME" 2>/dev/null | head -n 1)
    if [[ -n "$repo_found" ]]; then
        printf "Repository found at %s\n" "$repo_found"
        REPO_DIR="$repo_found"
    else
        # Default location to clone if not found
        local default_clone_path="$HOME/Desktop/$REPO_NAME"
        git clone "$REPO_URL" "$default_clone_path" || return 1
        REPO_DIR="$default_clone_path"
        printf "Repository cloned to %s\n" "$REPO_DIR"
    fi
}

# Move files to /usr/bin and /usr/lib, and set execute permission on the server
move_files_and_set_permissions() {
    printf "Moving files and setting permissions...\n"
    local lib_path="${REPO_DIR}/rknpu2/runtime/Linux/librknn_api/aarch64/"
    local bin_path="${REPO_DIR}/rknpu2/runtime/Linux/rknn_server/aarch64/usr/bin/"

    # Check if directories exist
    if [[ ! -d "$lib_path" ]]; then
        printf "Library path not found: %s\n" "$lib_path" >&2
        return 1
    fi
    if [[ ! -d "$bin_path" ]]; then
        printf "Binary path not found: %s\n" "$bin_path" >&2
        return 1
    fi

    # Copy files without quotes around wildcard to allow globbing
    sudo cp "${lib_path}librknnrt.so" /usr/lib/ || return 1
    sudo cp ${bin_path}* /usr/bin/ || return 1  # Unquoted to allow glob expansion
    sudo chmod +x /usr/bin/rknn_server || return 1

    printf "Files successfully moved to /usr/bin and /usr/lib, and permissions set on rknn_server.\n"
}

start_rknpu() {
    printf "Attempting to restart the RKNN server...\n"
    
    # Directly call the restart script without specifying the path
    restart_rknn.sh || {
        printf "Failed to restart the RKNN server. Please check the script for errors.\n" >&2
        return 1
    }
    printf "RKNN server restarted successfully.\n"
}

main() {
    if ! find_or_clone_repo; then
        printf "Failed to find or clone repository.\n" >&2
        return 1
    fi

    printf "About to move files and set permissions.\n"
    if ! move_files_and_set_permissions; then
        printf "Failed to move files and set permissions on rknn_server.\n" >&2
        return 1
    fi

    printf "About to restart rknpu server.\n"
    if ! start_rknpu; then
        printf "Failed to restart rknpu server.\n" >&2
        return 1
    fi
}

main "$@"
