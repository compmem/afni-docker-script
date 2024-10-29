
# AFNI Docker Script

A Bash script for simplifying use of the [afni/afni_make_build](https://hub.docker.com/r/afni/afni_make_build) Docker image for running AFNI on unsupported systems like Debian 13 (Trixie).

## Table of Contents
- [Requirements](#requirements)
- [Installation](#installation)
- [Explanation](#explanation)
  - [Why Use This Script?](#why-use-this-script)
- [Usage](#usage)
  - [Basic Commands](#basic-commands)
  - [Optional Flags](#optional-flags)
- [Troubleshooting](#troubleshooting)
  - [GUI Issues](#gui-issues)

## Requirements
- [Docker](https://www.docker.com/)
- Bash shell
- X11 (for GUI functionality)

## Installation

Clone this repository to your local machine:
```bash
git clone git@github.com:compmem/afni-docker-script.git
cd afni-docker-script
```

Make the script executable and move it to a directory in your PATH (e.g., `/usr/local/bin`):
```bash
chmod +x afni.sh
sudo mv afni.sh /usr/local/bin/afni
```

Before the first use, pull the `afni/afni_make_build` Docker image by running:
```bash
afni -u
```

This ensures that the latest version of the image is available on your system.

## Explanation

This script is designed to simplify working with [Containerized AFNI](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/container.html#) by using Docker to manage dependencies and run AFNI functions within a container.

### Why Use This Script?

As of November 2024, the AFNI package supports only Debian 9 (stretch), 10 (buster), and unstable (sid) distributions ([details here](https://neuro.debian.net/pkgs/afni.html#binary-pkg-afni)). Running AFNI on Debian 13 (Trixie) through Docker ensures compatibility and prevents package dependency issues associated with different distribution versions.

## Usage

The script has two primary modes:
1. **AFNI GUI Mode**: Launches the AFNI GUI.
2. **Command Mode**: Runs specified AFNI commands directly in the Docker container.

### Basic Commands

1. **Launch the AFNI GUI** (uses the current directory as the data directory):
   ```bash
   afni
   ```

2. **Run an AFNI command** (defaults to the current directory for data files):
   ```bash
   afni "<afni command and associated arguments>"
   ```
   - Example:
     ```bash
     afni "3dinfo -n4 dataset.nii"
     ```

### Optional Flags

- `-d, --data-directory <path>`: Specifies the data directory to be mounted in the container, overriding the default (current directory).
  - Example:
    ```bash
    afni -d /path/to/data "3dinfo -n4 dataset.nii"
    ```

- `-u, --update-image`: Pulls the latest `afni/afni_make_build` Docker image to ensure you’re using the most recent version.
  - Example:
    ```bash
    afni -u
    ```

- `-h, --help`: Displays help information about usage and available flags.
  - Example:
    ```bash
    afni -h
    ```

## Troubleshooting

### GUI Issues

The GUI functionality requires X11, as it mounts the host's X11 socket directory into the container to communicate with the display server. If you encounter GUI issues, verify the following:

- **X11 Windowing System**: Ensure you are using X11 as your windowing system, especially if your system defaults to Wayland. You can check this by running `echo $XDG_SESSION_TYPE`, which should output `x11`.
- **DISPLAY Variable**: Confirm that the `DISPLAY` environment variable is set correctly and matches your active display. Use `echo $DISPLAY` to check this.
- **X11 Access Permissions**: Ensure your Docker container has permission to access X11. Run `xhost +local:` on the host to allow local connections (not secure for multi-user environments; consider alternatives if needed).
