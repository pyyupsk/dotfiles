# PowerShell Setup Script

This script automates the installation and configuration of various PowerShell modules and tools, including Chocolatey, PSFzf, PSReadLine, Terminal-Icons, PowerType, and Oh-My-Posh. It also customizes your PowerShell profile with a stylish prompt and enhanced features.

## Prerequisites

-   Windows Operating System
-   Administrative privileges for installing certain components

## Features

-   Checks for administrative privileges
-   Installs Chocolatey if not already installed
-   Installs and configures PowerShell modules
-   Sets up a customized PowerShell profile
-   Downloads and configures Oh-My-Posh theme

## Usage

1. **Open PowerShell as Administrator**

    Ensure that you run PowerShell with administrative privileges to allow the script to install necessary components.

2. **Run the Script**

    Run the following command in PowerShell:

    ```powershell
    .\install_script.ps1
    ```

3. **Follow the Prompts**

    The script will automatically run the installation process and log each step to a file named `install_log.txt`.

## Manual Installation

If you prefer to install and configure the components manually, follow the steps outlined in the [Manual Installation Guide](manual-installation.md).

## Troubleshooting

If you encounter any issues during the installation process, refer to the log file `install_log.txt` for detailed information about each step. Common issues include:

-   Missing administrative privileges: Ensure you run PowerShell as an administrator.
-   Network connectivity: Make sure you have an active internet connection to download the necessary components.
-   Execution policy restrictions: Set the execution policy to `Bypass` temporarily if needed.

## Acknowledgments

-   [Chocolatey](https://chocolatey.org/)
-   [PSFzf](https://github.com/kelleyma49/PSFzf)
-   [PSReadLine](https://github.com/PowerShell/PSReadLine)
-   [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
-   [PowerType](https://github.com/PowerType/PowerType)
-   [Oh-My-Posh](https://ohmyposh.dev/)
