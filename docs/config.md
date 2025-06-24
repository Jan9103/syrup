# Configuration

Note: Many default settings assume you are using a [nerd font](https://www.nerdfonts.com).

## Prompt structure

`$env.SYRUP_PROMPT.prompt` contains the structure of your prompt.

The first level is a list of lines.

The second level is a list of elements.

The third level are the actual elements.

```nu
$env.SYRUP_PROMPT.prompt = [
  []  # empty line
  [
    'Hi'  # a element
  ]
]
$env.PROMPT_INDICATOR = '> '

# this would result in:
"\nHi> "
```

It is intended that you use `$env.PROMPT_INDICATOR*` for the actual indicator, since
it is impossible to get information about the `vi` mode.

### Element types:

* Raw text (just put a string `"foo"`)
  * mainly intended for separators
  * can also be used for non-changing things like `(hostname)` to save on resources.
  * example: `"> "`
* Builtin [module][modules]
  * format: a list:
    1. the module name (example: `pwd`)
    2. (optional) module configuration (a record)
    3. (optional) [modifiers][] (a record) (add behaviour, override things, etc)
  * example: `["pwd" {home: true}]`
* Custom module (closure)
  * you can do whatever you want here - no interference at all.
  * example: `{|| $env.CMD_DURATION_MS}`

## Further Reading

* [modules][]
* [modifiers][]

[modules]: ./modules.md
[modifiers]: ./modifiers.md
