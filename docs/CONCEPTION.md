## File structure: `install_<utility>.sh`

Any `install_<utility>.sh` file should contain the following functions:

> `_siu::prepare_install::<utility>`
>
> Download sources/binaries. Separated from the installation function in order to be used in offline installs.
>
> The working directory is `${SIU_SOURCES_DIR}/<utility>`.

> `_siu::install::<utility>`
>
> Install a utility, which sources or binaries have been downloaded using prepare_install.
>
> The working directory is a temporary directory (only for the build), all files that should be kept for the finished installed product should be put in the according `${SIU_UTILITIES_DIR}/<utility>` directory (it is this last directory that is removed when uninstalling). Keep in mind that the installation is meant to be a minimal install, which is why we build the tools in a temporary directory, and keep only the minimum files.
>  
> This function needs to create symlinks in the global SIU bin, man, etc. directories to this tool's binaries, manpages, etc.
> 
> Any line added to a SIU rc file should contain the string `_siu::install::<utility>`, which is used to dynamicaly remove it when uninstalling this utility.

Optional functions: those functions will be called if defined only, improving the default behaviour.

> `_siu::uninstall::<utility>`
>
> By default, `_siu::core::uninstall` will remove each utility's directory (`${SIU_UTILITIES_DIR}/<utility>`), remove any lines mentioning the tool from SIU's rc files (such as custom path, custom sourcing, etc.). Any line is only removed if it contains the string `_siu::install::<utility>`, so be sure to put this string (as a comment) on any line added when installing a utility.

> `_siu::get_latest_version::<utility>`
>
> If not defined, won't compare versions when updating and will just uninstall then re install utility.

> `_siu::check_installed::<utility>`
>
> If not defined, will use `_siu::check::command_exists` to check if the utility is installed.


