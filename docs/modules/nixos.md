# NixOS extra module

import: `modules/nixos.nu`

## `nix_shell`

### Configuration

```nu
const DEFAULT: record = {
  'format': {
    'shell': '󱄅 {purity}'
    'no_shell': ''

    'purity': {
      'impure': 'impure'
      'pure': 'pure'
    }
  }
}
```

Available placeholders:
* `purity` (formatted by `$.format.purity`)
