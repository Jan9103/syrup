# Builtin Modules

Notes:
* your module settings get merged with the defaults.
* "basic" modules are loaded by default. every other module has to be enabled via `load-env syrup/modules/<name>.nu` (example: `load-env syrup/modules/mpc.nu`)

Module Sections:
* [basic](./basic.md) (exit status, current directory, etc)
* [gitprompt](./gitprompt.md) (a re-implementation of [gitprompt](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh) for those who like to have the kitchen sink included)
* [mpc](./mpc.md) (status from the MPD "music player client" CLI tool)
* [rust](./rust.md)
