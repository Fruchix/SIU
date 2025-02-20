## File structure: `install_<module>.sh`

Any `install_<module>.sh` file should contain the following functions:

> `_siu::prepare_install::<module>`
>
> Download sources/binaries. Used for offline installs.

> `_siu::install::<module>`
>
> Install a module, which sources or binaries have been downloaded using prepare_install.

> `_siu::uninstall::<module>`
>
> Remove a module (also removes from rc files).



> `_siu::get_latest_version::<module>`
>
> If not defined, won't compare versions when updating and will just uninstall then re install module.

> `_siu::check_installed::<module>`
>
> If not defined, will use `_siu::check::command_exists` to check if the module is installed.


