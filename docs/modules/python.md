# Python extra module

import: `modules/python.nu`

## `python_venv`

Show the currently active venv.  
For the `python3 -m venv` implementation and compatible ones.  
Why? because that one is [endorsed by python](https://docs.python.org/3/library/venv.html) and AFAIK the original one.

### Configuration

```nu
const DEFAULT = {
  'format': {
    'venv': ' {venv_dir_parent_name}'
    'no_venv': ''
  }
}
```

Available placeholders (value if the venv is `/foo/.venv`):
* `venv_dir_abs`: `/foo/.venv`
* `venv_dir_name`: `.venv`
* `venv_dir_parent_abs`: `/foo`
* `venv_dir_parent_name`: `foo`
