# Gitprompt Module

A re-implementation of [the official git prompt for bash](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh) with some liberties taken.

## Configuration:

```nu
const DEFAULT = {
  'color': {  # argumenst for `ansi`
    'disable': false  # default with the original: no colors
    'ok': 'green'
    'bad': 'red'
    'flag': 'light_blue'
  }
  'parts': {
    'sparse': {  # <https://git-scm.com/docs/git-sparse-checkout>
      'show': false
      'compress': false  # no idea what this does - just copied it from the original
    }
    'conflict': {  # something can't be done automatically
      'show': false
    }
    'dirty': {  # something has changed since the last commit
      'show': false
    }
    'stash': {  # `git stash` has contents
      'show': false
    }
    'untracked': {  # check for untracked files
      'show': false
    }
    'upstream': {  # `git remote`
      'show': false
      'verbose': false  # show how many commits you are ahead and behind (requires 'ab')
      'ab': true  # show weather you are ahead, behind, or similar
      'name': false  # upstream name
    }
  }
  'hide_if_pwd_ignored': false  # if your current directory is in the `.gitignore` hide the git section
  'describe_style': 'default'  # 'default', 'describe', 'tag', 'branch', 'contains'
  'state_seperator': ' '

  'prefix': $" (ansi grey)\("
  'suffix': $"(ansi grey)\)"
}
```

## Explanation:

1. (optional) `BARE:` this is a `git clone --bare` repo
1. HEAD: branch, commit, etc (or `GIT_DIR!` if inside `.git`)
1. (optional) flags:
  1. `?`: sparse checkout (`parts.sparse.compress`)
  1. `*`: un-staged changes (`parts.dirty.show`)
  1. `+`: staged changes (`parts.dirty.show`)
  1. `#`: no commits and no staged changes (idk - the original has it)
  1. `$`: something is stashed (`parts.stash.show`)
  1. `%`: untracked file found (`parts.untracked.show`) (the original only shows this to zsh for some reason)
  1. `=`: same commit as upstream (`parts.upstream.show` and `parts.upstream.verbose = false`)
  1. `<`: behind upstream (`parts.upstream.show` and `parts.upstream.verbose = false`)
  1. `>`: ahead of upstream (`parts.upstream.show` and `parts.upstream.verbose = false`)
  1. `<>`: diverged from upstream (`parts.upstream.show` and `parts.upstream.verbose = false`)
1. (optional) `|SPARSE`: this is a sparse checkout (`parts.sparse.show`)
1. (optional) `|REBASE`: you are in the middle of a rebase
1. (optional) `|AM`: you are applying a rebase (unsure when this happens)
1. (optional) `|AM/REBASE`: either `AM` or `REBASE`
1. (optional) `|CHERRY-PICKING`: you are in the middle of a cherry pick
1. (optional) `|REVERTING`: you are reverting something
1. (optional) `|BISECTING`: you are bisecting
1. (optional) `|u`: status compared to upstream (`=` means equal, `+1` means 1 ahead, `-1` means 1 behind, `+1-1` means diverged) (`parts.upstream.show` and `parts.upstream.verbose`)
1. (optional) `upstream origin/main`: your current upstream branch is `origin/main`
1. (optional) `|CONFLICT`: there is a conflict (`parts.conflict.show`)
