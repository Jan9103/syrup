# Syrup (prompt)

A modular prompt for nushell.  

**PROJECT STATUS:** Alpha. (The parts i care about work, but there might still be bugs, missing basic features, etc)

![](screenshot)

## Roadmap (aka planned features)

Since i have everything i want i will probably be pretty slow.

* Make [powerline][]-style prompts easier / possible
* More builtin modules
  * last command duration (if long)
  * (session-)history length
* Examples
* More git-prompt configuration
  * Format string for complex parts like `upstream`
  * cfg variables for symbols
* right side prompt

## Installation

Using [numng](https://github.com/jan9103/numng_repo): `{"name": "jan9103/syrup", "version": "latest"}`

Otherwise:
```nu
### download ###
git clone --depth 0 https://github.com/jan9103/syrup

### add to config ###
$"\nsource-env ($env.PWD | path join syrup syrup mod.nu | to json)\n" | save --append $nu.config-path
```

## Configuration

* [docs](./docs/config.md)

[powerline]: https://github.com/b-ryan/powerline-shell
