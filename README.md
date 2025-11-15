# Syrup (prompt)

```
A modular progressive prompt for nushell.  
  ───┬─── ─────┬─────            ───┬───
     │         │                    ╰── https://nushell.sh
     │         ╰── It continues to fill in details after the initial render
     ╰── You chain prebuild configurable parts together
```

**PROJECT STATUS: ALPHA**
* The parts i care about work
* You can add what you want with custom modules
* It is not (yet) stable and config options/.. might get changed at any point
* The documentation is bad
* The only reason i published it (already) is that i don't think I'd have the motivation to finish it otherwise

![screenshot](https://jan9103.github.io/syrup/media/00.avif)
![screenshot](https://jan9103.github.io/syrup/media/bracketed.avif)
![screenshot](https://jan9103.github.io/syrup/media/pastel_powerline.avif)
![screenshot](https://jan9103.github.io/syrup/media/line1.avif)

(the screenshots are just examples)

## Quickstart

(copy and paste this into nu)

```nushell
cd ($nu.config-path | path dirname)
# download syrup
^git clone --depth=1 "https://github.com/Jan9103/syrup"
# add to nu config
"\n
# load syrup-prompt
source-env ./syrup/syrup/mod.nu
# load prompt modules
#source-env ./syrup/syrup/modules/gitprompt.nu

# set syrup-prompt config
#$env.SYRUP_PROMPT.prompt = [...]
#source-env ./syrup/examples/bracketed.nu
" | save --raw --append ./config.nu

cd  # go back to home-directory
^$nu.current-exe  # open a new nu instance to load the new config
```

**NOTE:** syrup's default configuration makes heavy use of [nerdfont](https://www.nerdfonts.com/).

Next steps:
* try out some [example configs](./examples)
* read the [docs](./docs/config.md)

[powerline]: https://github.com/b-ryan/powerline-shell
