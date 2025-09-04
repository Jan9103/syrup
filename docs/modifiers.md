# Modifiers

All modifiers get specified as a single record.  
The key is the modifier name and the value the modifier config.

## async

Render this module progressively.
meaning: It initially gets rendered as its placeholder and then gets filled in
as soon as it is ready.

Examples:
* `{async: {}}` (placeholder is a empty string)
* `{async: {placeholder: "<loading>"}}`

## color.admin

Change the color if you are a admin.  
Value: the `ansi` argument (color) to use.
Example: `{color: {"admin": "red"}}`

## color.color

Override the color.  
Value: the new color (as `ansi` argument).  
Example: `{color: {"color": "red"}}`

## color.exitcode

Override the color based on the exitcode.  
Example: `{color: {"exitcode": {"ok": "green", "err": "red"}}}`.  
If you don't include `ok` or `err` that result will result in no change.

## custom

A list of custom modifiers.  
Each should be a closure, which receives the current state via `stdin` and should result the updated one.  
Example: `{'custom': [{ str replace -a '/' '>' }]}` (makes a path powerline styled)
