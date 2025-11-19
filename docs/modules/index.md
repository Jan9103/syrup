# Builtin Modules

Notes:
* your module settings get merged with the defaults.
* "basic" modules are loaded by default. every other module has to be enabled via `load-env syrup/modules/<name>.nu` (example: `load-env syrup/modules/mpc.nu`)

## Module Sections:

* [basic](./basic.md) (exit status, current directory, etc)

OS specific:
* [Linux](./linux.md)
* [NixOS](./nixos.md)

language specific:
* [python](./python.md)
* [rust](./rust.md)

tool specific:
* [gitprompt](./gitprompt.md) (a re-implementation of [gitprompt](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh) for those who like to have the kitchen sink included)
* [mpc](./mpc.md) (status from the MPD "music player client" CLI tool)

### 3rd party modules

You can also just `source-env` those just like the ones included in this repo.

* [ajs.nu](https://github.com/Jan9103/ajs.nu/blob/main/ajs/syrup_prompt_module.nu): extensions for the nu job system (shows what the jobs are up to)
* [packer.nu](https://github.com/Jan9103/packer.nu/blob/main/api_layer/syrup_module.nu): package manager (shows degradation status)
