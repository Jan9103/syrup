# Setup

## External requirements

* [git](https://git-scm.com) (both for installing and the `gitprompt` module)
* (strongly recommended) any [nerdfont](https://www.nerdfonts.com) (the default settings make use of it)

## Download / "Installation"

`git clone --depth=1 https://github.com/jan9103/syrup` -> the module is at `$env.PWD | path join 'syrup' 'syrup'`

## Activation + Configuration

You can change your config at any point by just updating the env var. [config chapter](./config.md).

To activate it you have to add `source-env PATH_TO_SYRUP/mod.nu` (in my case: `source-env ~/git/jan9103/syrup/syrup/mod.nu`).

If you use any extra modules like `gitprompt` you have to put the `source-env PATH_TO_SYRUP/modules/<module>.nu` **AFTER** the base `mod.nu`.

### Resulting example `config.nu`

```nu
# i have installed it via:
# cd; mkdir git/jan9103; cd git/jan9103; git clone --depth=1 https://github.com/jan9103/syrup
source-env ~/git/jan9103/syrup/syrup/mod.nu  # <- load the base one FIRST
source-env ~/git/jan9103/syrup/syrup/modules/gitprompt.nu
source-env ~/git/jan9103/syrup/syrup/modules/mpc.nu

$env.SYRUP_PROMPT.prompt = [
  []  # empty line
  [
    ["pwd" {} {color: {admin: "red"}}]
    ["gitprompt"]
    ["overlay"]
    ["jobcount"]
    ['cmd_duration']
    ["mpc" {'format': {'paused': '', 'playing': ' 󰝚 {mode}{title}'}}]
  ]
  [
    ["exitstatus"]
  ]
]
```


[numng]: https://github.com/Jan9103/numng
