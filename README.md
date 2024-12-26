# Dotfiles Repository

This repository contains my personal dotfiles and configuration scripts for a customized development environment. It includes configurations for Zsh, aliases, functions, and various tools to enhance productivity.

## Table of Contents

- [Dotfiles Repository](#dotfiles-repository)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Aliases](#aliases)
    - [Functions](#functions)
  - [Components](#components)
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
   bash install/install-packages.sh
   ```

3. **Run the setup script:**

   ```bash
   cd ~/.dotfiles
   bash install/setup.sh
   ```

## Usage

After installation, you can start using the configured aliases and functions in your terminal. Open a new terminal session or source your `.zshrc` file to apply the changes:

```bash
source ~/.zshrc
```

### Aliases

You can use the following aliases for common tasks:

- `c`: Clear the terminal
- `mkdir`: Create directories with parents
- `gi`: Initialize a new Git repository
- `gs`: Show the Git status

### Functions

The repository includes several useful functions, such as:

- `command_not_found_handler`: Suggests packages for commands that are not found.
- `in`: Installs packages using the appropriate package manager.

## Components

- **Zsh Configuration**: Custom configurations for Zsh, including themes and plugins.
- **Aliases**: A collection of terminal aliases for common commands.
- **Functions**: Custom functions to enhance terminal usage.
- **Health Check Script**: A script to check system health and status.
- **Miscellaneous**: Additional scripts and configurations for tools like Zoxide and Pokemon Color Scripts.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
