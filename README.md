# Dotfiles Repository

This repository contains my personal dotfiles and configuration scripts for a customized development environment. It includes configurations for Zsh, aliases, functions, and various tools to enhance productivity.

> [!NOTE]
> This repository is under development, and more configurations will be added in the future.

## Table of Contents

- [Dotfiles Repository](#dotfiles-repository)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [License](#license)

## Installation

To set up the dotfiles on your system, follow these steps:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/pyyupsk/dotfiles.git ~/.dotfiles
   ```

2. **Install required packages:**
   Make sure to run the `install/install-packages.sh` script to install necessary packages:

   ```bash
   sudo sh ~/.dotfiles/install/install-packages.sh
   ```

3. **Run the setup script:**

   ```bash
   sh ~/.dotfiles/install/setup.sh
   ```

> [!WARNING]
> Ensure that you have backed up your existing configuration files before running the setup scripts to prevent any data loss.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
