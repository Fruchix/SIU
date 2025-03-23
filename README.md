# SIU (Setup and Install Utilities)

SIU is a command-line tool that allows users to install essential utilities such as `zsh`, `fzf`, `tree`, `bat`, and more, without requiring root access.

## Features
- Install various utility programs without root permissions.
- Check for updates and update installed tools. \[Not implemented yet]
- Uninstall tools as needed.
- Prepare offline installations by downloading sources in advance.
- Check dependencies before installation.
- Support for different installation modes, including bulk installations of multiple tools at once.

## Usage
```bash
siu MODE [tool]... [OPTION]...
siu MODE TOOLSET_OPTION [OPTION]...
```

### Modes
- `install, i` – Install the selected tools.
- `check_update, cu` – Check if installed tools are at the latest version. \[Not implemented yet]
- `update, u` – Update selected tools that are outdated (default: update all tools). \[Not implemented yet]
- `uninstall, remove, rm` – Remove selected tools.
- `prepare, p` – Download tool archives/repositories into `$SIU_SOURCES_DIR` for offline installation. Requires `--arch=<arch>`.
- `check_dependencies, cd` – Verify if the selected tools can be installed without performing the installation.
- `help, h, -h, --help` – Display usage information.

### Toolset options (Mutually Exclusive)
- `--default, -D` – Install a predefined set of default tools.
- `--all, -A` – Install all available tools, regardless of system presence. If used with `--force`, force-downloads sources (overwrites previously downloaded sources).
- `--missing, -M` – Install only the tools that are missing from the system.
- `--tools, --selection, -T, -S <tool1> [tool2] ...` – Install a custom set of tools. (Which is the same as just putting the tool names after the MODE)

### Options
- `--arch=<arch>` – Specify machine architecture (auto-detected if omitted). Required for `prepare` mode.
- `--offline` – Use only pre-downloaded sources from `$SIU_SOURCES_DIR`. No new downloads.
- `--force, -f` – Install selected tools even if already installed, and force source downloads.
  - To only force source downloads (which overwrites previously downloaded sources), run `prepare` with `--force` first, then `install` without `--force`.
- `--config-file, -c <config_file>` – Specify a configuration file.
- `--verbose, -v` – Enable detailed logging. Can be used more than once.

## Example usage
### Installing tools

#### Custom set
```bash
siu install zsh fzf tree
```

#### Tools that are missing from the system
```bash
siu install -M
```

#### Default set
```bash
siu install --default
```

### Checking for updates \[Not implemented yet]
```bash
siu check_update
```

### Updating all installed tools \[Not implemented yet]
```bash
siu update
```

### Preparing for offline installation (x86_64 Architecture)
```bash
siu prepare --arch=x86_64
```

### Uninstalling tools
```bash
siu uninstall zsh fzf
```

## Installation
Clone the repository anywhere and run the installation script.
This script moves the SIU directory (that you just cloned) to `$HOME/.siu`, which means that you do not have to clone it in in a special directory.

See [Files and Modifications](#files-and-modifications) for information on changes SIU makes to your system.
```bash
git clone https://github.com/Fruchix/SIU.git
./SIU/install
```

Source your `bashrc` or `zshrc` again.

```bash
source ~/.bashrc
```

```bash
source ~/.zshrc
```

## Uninstallation

Run the following script:
```bash
./${SIU_DIR}/uninstall
```

## Files and Modifications

SIU is self contained in the `$HOME/.siu` directory, which is also used for storing downloaded sources and installed tools. 
Additionally, it modifies only the `.bashrc` and `.zshrc` files to add three lines required for functionality. 
These lines can be automatically removed by SIU if uninstallation is performed.


## Requirements

This software has been developed on bash >= 5.2, untested on prior versions (pretty sure it does not work on bash 3).

It uses GNU tools and coreutils, which are not always the default (e.g. find exists on MacOS, but does not have the same options as the GNU version).

On MacOS, GNU utils can be installed using brew: https://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities.

## License
This project is licensed under the Apache License, Version 2.0 (the "License").

## Contributing
Contributions are welcome! Please submit issues or pull requests to improve SIU.

## Author
Copyright 2025 Fruchix

