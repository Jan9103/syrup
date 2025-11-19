# Linux modules

Modules which can be implemented more efficiently for Linux
or are simply nonsensical for other OSes.

Some of these might work on other OS, but no guarantees

## `linux_load`

### Configuration

```nushell
const DEFAULT: record = {
  'high_load': 3.0  # anything >= this will use the high_load format
  'time': 1min  # or 5min or 15min

  'format': {
    'high_load': $'(ansi red) {load}(ansi reset) '
    'low_load': ''
  }
}
```

available placeholders:
* `load`: load average for the selected `$.time`-span
* `load1`:  1min load average
* `load5`:  5min load average
* `load15`: 15min load average
