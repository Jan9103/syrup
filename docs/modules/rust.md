# Rust extra modules

import: `modules/rust.nu`

## `rust_version`

Shows the version of `rustc` used for the current directory.

### Configuration

```nu
const DEFAULT = {
  'format': {
    # "Cargo.toml" exists somewhere in a parent directory
    'in_cargo_dir': $' (ansi red) {version}(ansi reset)'
    'otherwise': ''
  }
}
```

Available placeholders:
* `version`: example `1.85.1`
* `hash`: example `4eb161250`
* `date`: example `2025-03-15`
* `year`: example `2025` (this is a shortened version of `date` and not related to official year release thingies)
