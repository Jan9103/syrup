# Basic Modules

Note: your module settings get merged with the defaults.

## pwd

Shows the current directory (`$env.PWD`).

### Configuration:

```nu
const DEFAULT = {
  'prefix_element': {  # a path element, which gets injected
    'default': ''  # (nerdfont: root folder)
    'home': '~'
    'git': ''  # (nerdfont: git)
    'shortened': '…'
  }
  'format': {  # format strings depending on what it chose as base-directory
    'default': $'(ansi blue){path}(ansi reset)'
    'home': $'(ansi cyan){path}(ansi reset)'
    'git': $'(ansi green){path}(ansi reset)'
    'shortened': $'(ansi yellow){path}(ansi reset)'  # 'max_elements'

    'element': '{element}'  # format string for induvidual path elements
  }
  'seperator': '/'  # seperator for the path elements
  'git': true  # use git directories as base directory if possible
  'home': true  # use the home directory as base directory if possible
  'max_elements': 5  # (int) limit the count of path-elements (null = unlimited)
}
```

## overlay

Shows active nushell overlay (`overlay --help`).

### Configuration:

```nu
const DEFAULT = {
  'seperator': '>'  # seperator between overlays
  'ignore': ['zero']  # overlays to not show (`zero` is the default one)
  'limit': null  # (int) limit the amount of overlays shown (null = unlimited)
  'format': $" (ansi green){overlays}(ansi reset)"
}
```

## exitstatus

Shows the exit status of the last command.

### Configuration:

```nu
const DEFAULT = {
  'show_ok': false  # if false it will be completely hidden if the exitstatus is ok (0)
  'format': {
    'err': $' (ansi red)x{status}(ansi reset)'
    'ok': $' (ansi green)x{status}(ansi reset)'
  }
}
```

## datetime

### Configuration

```nu
const DEFAULT = {
  'format': '%H:%M:%S'  # `format date` format
}
```

## jobcount

How many nu background processes are there.

### Configuration

```nu
const DEFAULT = {
  'show_0': false
  'format': ' 󱇫{count}'  # (nerdfont spider)
}
```

## cmd_duration

### Configuration

```nu
const DEFAULT = {
  'min': 5sec
  'format': $' (ansi red){duration}(ansi reset)'
}
```

## git_branch

### Configuration

```nu
const DEFAULT = {
  'format': {
    'branch': $' (ansi green){branch}(ansi reset)'  # (nerdfont git-branch-symbol)
    'detached': $' (ansi yellow){short_sha}(ansi reset)'  # (nerdfont git-symbol)
    'not_git': ''
  }
}
```
