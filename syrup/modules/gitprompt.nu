use std/util [null-device]

const DEFAULT_CONFIG: record = {
  'color': {
    'disable': false
    'ok': 'green'
    'bad': 'red'
    'flag': 'light_blue'
  }
  'parts': {
    'sparse': {
      'show': false  # $env.GIT_PS1_OMITSPARSESTATE == ''
      'compress': false  # $env.GIT_PS1_COMPRESSSPARSESTATE != ''
    }
    'conflict': {
      'show': false  # $env.GIT_PS1_SHOWCONFLICTSTATE == 'yes'
    }
    'dirty': {
      'show': false  # $env.GIT_PS1_SHOWDIRTYSTATE != ''
    }
    'stash': {
      'show': false  # $env.GIT_PS1_SHOWSTASHSTATE != ''
    }
    'untracked': {
      'show': false  # $env.GIT_PS1_SHOWUNTRACKEDFILES != ''
    }
    'upstream': {
      'show': false  # $env.GIT_PS1_SHOWUPSTREAM != ''
      'verbose': false
      'ab': true  # ahead behind
      'name': false  # upstream name
    }
  }
  'hide_if_pwd_ignored': false
  'describe_style': 'default'  # 'default', 'describe', 'tag', 'branch', 'contains'  # $env.GIT_PS1_DESCRIBE_STYLE | default 'default'
  'state_seperator': ' '  # $env.GIT_PS1_STATESEPARATOR  | default ' '

  'prefix': $" (ansi grey)\("
  'suffix': $"(ansi grey)\)"
}

export-env {
  $env.SYRUP_PROMPT_MODULES.gitprompt = {|cfg|
    let cfg: record = ($DEFAULT_CONFIG | merge deep $cfg)

    let repo_info: list<string> = (
      ^git rev-parse --git-dir --is-inside-git-dir --is-bare-repository --is-inside-work-tree --show-ref-format --short HEAD
      e> (null-device)  # e>| for some reason swallows stdout, so a workaround it is
      | lines
    )
    if ($repo_info | is-empty) {  # not inside a git dir
      return ''
    }
    let g: path = $repo_info.0  # "g" in original
    let is_inside_gitdir: bool = ($repo_info.1 | into bool)
    let is_bare_repo: bool = ($repo_info.2 | into bool)
    let is_inside_worktree: bool = ($repo_info.3 | into bool)
    let ref_format: string = $repo_info.4
    let short_sha: string = ($repo_info.5? | default '')

    if (
      ($is_inside_worktree)
      and ($cfg.hide_if_pwd_ignored)
      and (^git check-ignore -q . | complete).exit_code == 0
    ) { return '' }

    let sparse: string = (
      if (
        ($cfg.parts.sparse.show)
        and (not $cfg.parts.sparse.compress)
        and ((^git config --bool core.sparseCheckout) == true)
      ) { "|SPARSE" } else { "" }
    )

    mut r: string = ""
    mut b: string = ""
    mut step: string = ""
    mut total: string = ""

    mut detached: bool = false

    if ($g | path join 'rebase-merge' | path type) == 'dir' {
      $b = (open --raw ($g | path join 'rebase-merge' 'head-name') | str trim)
      $step = (open --raw ($g | path join 'rebase-merge' 'msgnum') | str trim)
      $total = (open --raw ($g | path join 'rebase-merge' 'end') | str trim)
      $r = "|REBASE"
    } else {
      if ($g | path join 'rebase-apply' | path type) == 'dir' {
        $step = (open --raw ($g | path join 'rebase-apply' 'next') | str trim)
        $total = (open --raw ($g | path join 'rebase-apply' 'last') | str trim)
        if ($g | path join 'rebase-apply' 'rebasing' | path type) == 'file' {
          $b = (open --raw ($g | path join 'rebase-apply' 'head-name') | str trim)
          $r = '|REBASE'
        } else if ($g | path join 'rebase-apply' 'applying' | path type) == 'file' {
          $r = '|AM'
        } else {
          $r = '|AM/REBASE'
        }
      } else if ($g | path join 'MERGE_HEAD' | path type) == 'file' {
        $r = '|MERGING'
      } else if (try {
        mut todo: string = ''
        if ($g | path join 'CHERRY_PICK_HEAD' | path type) == 'file' {
          $r = '|CHERRY-PICKING'
          true
        } else if ($g | path join 'REVERT_HEAD' | path type) == 'file' {
          $r = '|REVERTING'
          true
        } else if (try { $todo = (open --raw ($g | path join 'sequencer' 'todo') | str trim); true } catch { false }) {
          if $todo =~ 'p(ick)? *' {
            $r = '|CHERRY-PICKING'
          } else if $todo =~ 'revert *' {
            $r = '|REVERTING'
          }
          true
        } else {
          false
        }
      } catch { false }) {
        # noop
      } else if ($g | path join 'BISECT_LOG' | path type) == 'file' {
        $r = '|BISECTING'
      }

      if $b != '' {
        # noop
      } else if ($g | path join 'HEAD' | path type) == 'symlink' {
        $b = (^git symbolic-ref HEAD e> (null-device) | str trim)
      } else {
        mut head: string = ''

        if $ref_format == 'files' {
          try {
            $head = (open --raw ($g | path join 'HEAD') | str trim)
          } catch { return '' }

          if ($head | str starts-with 'ref: ') {
            $head = ($head | str replace -r '^ref: ' '')
          } else {
            $head = ''
          }
        } else {
          $head = (^git symbolic-ref HEAD e> (null-device) | str trim)
        }

        if $head == '' {
          $detached = true
          if (try {
            match $cfg.describe_style {
              'contains' => { $b = (^git describe --contains HEAD e> (null-device) | str trim) }
              'branch' => { $b = (^git describe --contains --all HEAD e> (null-device) | str trim) }
              'tag' => { $b = (^git describe --tags HEAD e> (null-device) | str trim) }
              'describe' => { $b = (^git describe HEAD e> (null-device) | str trim) }
              'default' => { $b = (^git describe --tags --exact-match HEAD e> (null-device) | str trim) }
            }
            # for some reason non-0 exit codes only sometimes cause a `try` error
            $env.LAST_EXIT_CODE != '0'
          } catch {
            true
          }) {
            $b = $'($short_sha)...'
          }
          $b = $"\(($b)\)"
        } else {
          $b = $head
        }
      }
    }  # end of $b == ''

    if $step != '' and $total != '' {
      $r = $'($r) ($step)/($total)'
    }

    let conflict: string = (if (
      ($cfg.parts.conflict.show)
      and ((try { ^git ls-files --unmerged e> (null-device) } catch { '' }) != '')
    ) {
      '|CONFLICT'
    } else { '' })

    mut w: string = ''
    mut i: string = ''
    mut u: string = ''
    mut h: string = ''
    mut c: string = ''
    mut p: string = ''
    mut s: string = ''
    mut upstream: string = ''

    if $is_inside_gitdir {
      if $is_bare_repo {
        $c = 'BARE:'
      } else {
        $b = 'GIT_DIR!'
      }
    } else if $is_inside_worktree {
      if $cfg.parts.dirty.show {
        if (try { ^git diff --no-ext-diff --quiet; false } catch { true }) {
          $w = '*'
        }
        if (try { ^git diff --no-ext-diff --cached --quiet; false } catch { true }) {
          $i = '+'
        }
        if $short_sha == '' and $i == '' {
          $i = '#'
        }
      }  # end dirty

      $s = (if (
        ($cfg.parts.stash.show)
        and (try { ^git rev-parse --verify --quiet refs/stash o+e> (null-device); true } catch { false })
      ) { '$' } else { '' })

      if (
        ($cfg.parts.untracked.show)
        and (try { ^git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' o+e> (null-device); true } catch { false })
      ) {
        # for some reason the original '/usr/share/git/git-prompt.sh' only shows this inside of zsh.. idk why
        $u = '%'
      }

      if (
        ($cfg.parts.sparse.compress)
        and (try { ^git config --bool core.sparseCheckout; true } catch { false })
      ) {
        $h = '?'
      }

      if $cfg.parts.upstream.show {
        # this diverges a lot from the original, but i dont want to figure
        # out the svn related spagetti since noone uses that anymore..

        mut no_upstream: bool = false

        let ab: string = (if $cfg.parts.upstream.ab { match (try {
          ^git rev-list --count --left-right "@{upstream}...HEAD" e> (null-device)
          | split words
          | into int
        } catch { null }) {
          null => { $no_upstream = true; '' }  # no upstream
          [0, 0] => { if $cfg.parts.upstream.verbose { '|u=' } else { $p = '='; '' } }  # no divergence
          [0, $ahead] => { if $cfg.parts.upstream.verbose { $'|u+($ahead)' } else { $p = '>'; '' } }  # ahead
          [$behind, 0] => { if $cfg.parts.upstream.verbose { $'|u-($behind)' } else { $p = '<'; '' } }  # behind
          [$behind, $ahead] => { if $cfg.parts.upstream.verbose { $'|u+($ahead)-($behind)' } else { $p = '<>'; '' } }  # diverged
        } } else { '' })

        let name = (if ((not $no_upstream) and ($cfg.parts.upstream.name)) {
          ^git rev-parse --abbrev-ref '@{upstream}' e> (null-device)
          | str trim
          | if $in == '' { $no_upstream = true; '' } else { $'upstream ($in)' }
        } else { '' })

        $upstream = (match [$ab, $name] {
          ['', ''] => { '' }
          ['', $name] => { $name }
          [$ab, ''] => { $ab }
          [$ab, $name] => { $'($ab) ($name)' }
        })
      }
    }  # end of $is_inside_worktree


    let z = $cfg.state_seperator

    if ($b | str starts-with 'refs/heads/') {
      $b = ($b | str replace -r '^refs/heads/' '')
    }

    if not $cfg.color.disable {
      let branch_color: string = (ansi (if $detached { $cfg.color.bad } else { $cfg.color.ok }))
      if $c != '' {
        $c = $"($branch_color)($c)(ansi reset)"
      }
      $b = $"($branch_color)($b)(ansi reset)"
      if $w != '' {
        $w = $"(ansi $cfg.color.bad)($w)(ansi reset)"
      }
      if $i != '' {
        $i = $"(ansi $cfg.color.ok)($i)(ansi reset)"
      }
      if $s != '' {
        $s = $'(ansi $cfg.color.flag)($s)(ansi reset)'
      }
      if $u != '' {
        $u = $'(ansi $cfg.color.bad)($u)(ansi reset)'
      }
    }

    let f = $'($h)($w)($i)($s)($u)($p)'
    let gitstring = $"($c)($b)(if $f != '' { $'($z)($f)' } else { '' })($sparse)($r)($upstream)($conflict)"

    $'($cfg.prefix)($gitstring)($cfg.suffix)(ansi reset)'
  }
}
