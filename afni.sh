#!/bin/bash

# AFNI Docker Helper Script for AFNI
# Requirements: Docker and X11

# Constants
readonly SCRIPT_NAME="$(basename "$0" .sh)"

# Function to update the AFNI Docker image
afni_update_image() {
    echo "Updating AFNI Docker image..."
    docker pull afni/afni_make_build && echo "AFNI Docker image updated."
}

# Retrieve users_gid (for cleaner code)
get_users_gid() {
    getent group users | cut -d: -f3
}

# Function to launch the AFNI GUI
afni_gui() {
    local data_directory="${1:-$PWD}"  # Default to current directory if no argument is provided
    local users_gid=$(get_users_gid)   # Get the group ID of the 'users' group

    echo "Starting AFNI GUI with data directory: $data_directory"
    docker run --rm -ti \
        --user="$(id -u):${users_gid}" \
        --group-add root \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=${DISPLAY} \
        -v "$data_directory":/opt/home/data_directory \
        -w /opt/home/data_directory \
        afni/afni_make_build afni -no_detach
}

# Function to run an AFNI command
afni_command() {
    local data_directory="$PWD"  # Default data directory
    local command=""             # Command to run in Docker
    local users_gid=$(get_users_gid)  # Get the group ID of the 'users' group

    # Parse flags
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -d|--data-directory)
                shift
                data_directory="$1"  # Set the data directory to the specified argument
                ;;
            -u|--update-image)
                afni_update_image
                return 0
                ;;
            -h|--help)
                display_help
                return 0
                ;;
            *)
                command="$1"  # Set command to the first positional argument
                ;;
        esac
        shift
    done

    # Ensure the data directory exists
    if [[ ! -d "$data_directory" ]]; then
        echo "Error: Directory $data_directory does not exist."
        return 1
    fi

    # If no command is provided, launch the GUI
    if [[ -z "$command" ]]; then
        echo "Launching AFNI GUI..."
        afni_gui "$data_directory"
        return 0
    fi

    # Run the Docker command with the specified settings
    echo "Running AFNI command: $command with data directory: $data_directory"
    docker run --rm -ti \
        --user="$(id -u):${users_gid}" \
        --group-add root \
        -v "$data_directory":/opt/home/data_directory \
        -w /opt/home/data_directory \
        afni/afni_make_build $command
}

# Display help and usage information
display_help() {
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cat << EOF
Usage: $SCRIPT_NAME [command] [options]

Options:
  -d, --data-directory <dir>  Set the AFNI data directory (default: current directory)
  -u, --update-image          Pull the latest AFNI Docker image
  -h, --help                  Show this help message

Examples:
  $SCRIPT_NAME                              # Launches AFNI GUI with current directory as data directory
  $SCRIPT_NAME "3dinfo -n4 dataset.nii"     # Runs the AFNI command
  $SCRIPT_NAME -d /path/to/data             # Specifies data directory & launches GUI

Further Information:
  - Ensure Docker is installed and running
  - X11 display must be configured correctly for GUI use
  - Script Location: $script_path
  - Source Code & Docs: https://github.com/compmem/afni-docker-script"
EOF
}

# Ensure Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Ensure DISPLAY is set for X11
if [[ -z "$DISPLAY" ]]; then
    echo "Error: DISPLAY variable is not set. Ensure X11 is configured for GUI use."
    exit 1
fi

# Main entry point to process arguments
afni_command "$@"
