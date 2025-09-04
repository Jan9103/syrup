use ../util.nu [null_device]

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

  'format': {
    'sparse': {
      'yes': '|SPARE'
      'no': ''
    }
    'action': {
      'with_steps': '{action} ({step}/{total})'

      'rebase': '|REBASE'
      'applying': '|AM'
      'rebase-applying': '|AM/REBASE'
      'merging': '|MERGING'
      'cherry-picking': '|CHERRY-PICKING'
      'reverting': '|REVERTING'
      'bisecting': '|BISECTING'
    }
    'bare': 'BARE:'
    'conflict': {
      'yes': '|CONFLICT'
      'no': ''
    }
    'ref': {
      'short_sha': '{short_sha}...'
      'detached': '({git_ref})'
      'git_dir': 'GIT_DIR!'
    }
    'dirt_markers': {
      'staged': '+'
      'unstaged': '*'
      'no_commits': '#'
    }
    'untracked_marker': '%'
    'sparse_marker': '?'
    'verbose_upstream': {
      'equal': '|u='
      'ahead': '|u+{ahead}'
      'behind': '|u-{behind}'
      'diverged': '|u+{ahead}-{behind}'
    }
    'short_upstream': {
      'equal': ''
      'ahead': '>'
      'behind': '<'
      'diverged': '<>'
    }
    'upstream_name': 'upstream {name}'
  }
}

export-env {
  $env.SYRUP_PROMPT_MODULES.gitprompt = {|cfg|
    let cfg: record = ($DEFAULT_CONFIG | merge deep $cfg)

    let repo_info: list<string> = (
      ^git rev-parse --git-dir --is-inside-git-dir --is-bare-repository --is-inside-work-tree --show-ref-format --short HEAD
      e> ($null_device)  # e>| for some reason swallows stdout, so a workaround it is
      | lines
    )
    if ($repo_info | is-empty) {  # not inside a git dir
      return ''
    }
    let git_dir: path = $repo_info.0
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
        and ((try { ^git config --bool core.sparseCheckout; true } catch { false }) == true)
      ) { $cfg.format.sparse.yes } else { $cfg.format.sparse.no }
    )

    mut current_wip_git_action: string = ""
    mut git_ref: string = ""
    mut step: string = ""
    mut total: string = ""

    mut detached: bool = false

    if ($git_dir | path join 'rebase-merge' | path type) == 'dir' {
      $git_ref = (open --raw ($git_dir | path join 'rebase-merge' 'head-name') | str trim)
      $step = (open --raw ($git_dir | path join 'rebase-merge' 'msgnum') | str trim)
      $total = (open --raw ($git_dir | path join 'rebase-merge' 'end') | str trim)
      $current_wip_git_action = $cfg.format.action.rebase
    } else {
      if ($git_dir | path join 'rebase-apply' | path type) == 'dir' {
        $step = (open --raw ($git_dir | path join 'rebase-apply' 'next') | str trim)
        $total = (open --raw ($git_dir | path join 'rebase-apply' 'last') | str trim)
        if ($git_dir | path join 'rebase-apply' 'rebasing' | path type) == 'file' {
          $git_ref = (open --raw ($git_dir | path join 'rebase-apply' 'head-name') | str trim)
          $current_wip_git_action = $cfg.format.action.rebase
        } else if ($git_dir | path join 'rebase-apply' 'applying' | path type) == 'file' {
          $current_wip_git_action = $cfg.format.action.applying
        } else {
          $current_wip_git_action = $cfg.format.action."rebase-applying"
        }
      } else if ($git_dir | path join 'MERGE_HEAD' | path type) == 'file' {
        $current_wip_git_action = $cfg.format.action.merging
      } else if (try {
        mut todo: string = ''
        if ($git_dir | path join 'CHERRY_PICK_HEAD' | path type) == 'file' {
          $current_wip_git_action = $cfg.format.action.'cherry-picking'
          true
        } else if ($git_dir | path join 'REVERT_HEAD' | path type) == 'file' {
          $current_wip_git_action = $cfg.format.action.reverting
          true
        } else if (try { $todo = (open --raw ($git_dir | path join 'sequencer' 'todo') | str trim); true } catch { false }) {
          if $todo =~ 'p(ick)? *' {
            $current_wip_git_action = $cfg.format.action.'cherry-picking'
          } else if $todo =~ 'revert *' {
            $current_wip_git_action = $cfg.format.action.reverting
          }
          true
        } else {
          false
        }
      } catch { false }) {
        # noop
      } else if ($git_dir | path join 'BISECT_LOG' | path type) == 'file' {
        $current_wip_git_action = $cfg.format.action.bisecting
      }

      if $git_ref != '' {
        # noop
      } else if ($git_dir | path join 'HEAD' | path type) == 'symlink' {
        $git_ref = (^git symbolic-ref HEAD e> ($null_device) | str trim)
      } else {
        mut head: string = ''

        if $ref_format == 'files' {
          try {
            $head = (open --raw ($git_dir | path join 'HEAD') | str trim)
          } catch { return '' }

          if ($head | str starts-with 'ref: ') {
            $head = ($head | str replace -r '^ref: ' '')
          } else {
            $head = ''
          }
        } else {
          $head = (^git symbolic-ref HEAD e> ($null_device) | str trim)
        }

        if $head == '' {
          $detached = true
          if (try {
            match $cfg.describe_style {
              'contains' => { $git_ref = (^git describe --contains HEAD e> ($null_device) | str trim) }
              'branch' => { $git_ref = (^git describe --contains --all HEAD e> ($null_device) | str trim) }
              'tag' => { $git_ref = (^git describe --tags HEAD e> ($null_device) | str trim) }
              'describe' => { $git_ref = (^git describe HEAD e> ($null_device) | str trim) }
              'default' => { $git_ref = (^git describe --tags --exact-match HEAD e> ($null_device) | str trim) }
            }
            # for some reason non-0 exit codes only sometimes cause a `try` error
            $env.LAST_EXIT_CODE != '0'
          } catch {
            true
          }) {
            $git_ref = ({'short_sha': $short_sha} | format pattern $cfg.format.ref.short_sha)
          }
          $git_ref = ({'git_ref': $git_ref} | format pattern $cfg.format.ref.detached)
        } else {
          $git_ref = $head
        }
      }
    }  # end of $b == ''

    if $step != '' and $total != '' {
      $current_wip_git_action = ({'action': $current_wip_git_action, 'step': $step, 'total': $total} | format pattern $cfg.format.action.with_steps)
    }

    let conflict: string = (if (
      ($cfg.parts.conflict.show)
      and ((try { ^git ls-files --unmerged e> ($null_device) } catch { '' }) != '')
    ) { $cfg.format.conflict.yes } else { $cfg.format.conflict.no })

    mut unstaged_indicator: string = ''
    mut staged_or_no_commit_indicator: string = ''
    mut untracked_indicator: string = ''
    mut sparse_checkout_indicator: string = ''
    mut bare_indicator: string = ''
    mut short_ahead_behind: string = ''
    mut stash_indicator: string = ''
    mut upstream: string = ''

    if $is_inside_gitdir {
      if $is_bare_repo {
        $bare_indicator = $cfg.format.bare
      } else {
        $git_ref = $cfg.format.ref.git_dir
      }
    } else if $is_inside_worktree {
      if $cfg.parts.dirty.show {
        if (try { ^git diff --no-ext-diff --quiet; false } catch { true }) {
          $unstaged_indicator = $cfg.format.dirt_marker.unstaged
        }
        if (try { ^git diff --no-ext-diff --cached --quiet; false } catch { true }) {
          $staged_or_no_commit_indicator = $cfg.format.dirt_markers.staged
        }
        if $short_sha == '' and $staged_or_no_commit_indicator == '' {
          $staged_or_no_commit_indicator = $cfg.format.dirt_markers.no_commits
        }
      }  # end dirty

      $stash_indicator = (if (
        ($cfg.parts.stash.show)
        and (try { ^git rev-parse --verify --quiet refs/stash o+e> ($null_device); true } catch { false })
      ) { '$' } else { '' })

      if (
        ($cfg.parts.untracked.show)
        and (try { ^git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' o+e> ($null_device); true } catch { false })
      ) {
        # for some reason the original '/usr/share/git/git-prompt.sh' only shows this inside of zsh.. idk why
        $untracked_indicator = $cfg.format.untracked_marker
      }

      if (
        ($cfg.parts.sparse.compress)
        and (try { ^git config --bool core.sparseCheckout; true } catch { false })
      ) {
        $sparse_checkout_indicator = $cfg.format.sparse_marker
      }

      if $cfg.parts.upstream.show {
        # this diverges a lot from the original, but i dont want to figure
        # out the svn related spagetti since noone uses that anymore..

        mut no_upstream: bool = false

        let ab: string = (if $cfg.parts.upstream.ab { match (try {
          ^git rev-list --count --left-right "@{upstream}...HEAD" e> ($null_device)
          | split words
          | into int
        } catch { null }) {
          null => { $no_upstream = true; '' }  # no upstream
          [0, 0] =>            { $short_ahead_behind = $cfg.format.short_upstream.equal;    $cfg.format.verbose_upstream.equal }
          [0, $ahead] =>       { $short_ahead_behind = $cfg.format.short_upstream.ahead;    {'ahead':  $ahead}  | format pattern $cfg.format.verbose_upstream.ahead }
          [$behind, 0] =>      { $short_ahead_behind = $cfg.format.short_upstream.behind;   {'behind': $behind} | format pattern $cfg.format.verbose_upstream.behind }
          [$behind, $ahead] => { $short_ahead_behind = $cfg.format.short_upstream.diverged; {'ahead': $ahead, 'behind': $behind} | format pattern $cfg.format.verbose_upstream.diverged }
        } } else { '' })

        let name = (if ((not $no_upstream) and ($cfg.parts.upstream.name)) {
          ^git rev-parse --abbrev-ref '@{upstream}' e> ($null_device)
          | str trim
          | if $in == '' { $no_upstream = true; '' } else { {'name': $in} | format pattern $cfg.format.upstream_name }
        } else { '' })

        $upstream = (match [$ab, $name] {
          ['', ''] => { '' }
          ['', $name] => { $name }
          [$ab, ''] => { $ab }
          [$ab, $name] => { $'($ab) ($name)' }
        })
      }
    }  # end of $is_inside_worktree


    let state_seperator = $cfg.state_seperator

    if ($git_ref | str starts-with 'refs/heads/') {
      $git_ref = ($git_ref | str replace -r '^refs/heads/' '')
    }

    if not $cfg.color.disable {
      let branch_color: string = (ansi (if $detached { $cfg.color.bad } else { $cfg.color.ok }))
      if $bare_indicator != '' {
        $bare_indicator = $"($branch_color)($bare_indicator)(ansi reset)"
      }
      $git_ref = $"($branch_color)($git_ref)(ansi reset)"
      if $unstaged_indicator != '' {
        $unstaged_indicator = $"(ansi $cfg.color.bad)($unstaged_indicator)(ansi reset)"
      }
      if $staged_or_no_commit_indicator != '' {
        $staged_or_no_commit_indicator = $"(ansi $cfg.color.ok)($staged_or_no_commit_indicator)(ansi reset)"
      }
      if $stash_indicator != '' {
        $stash_indicator = $'(ansi $cfg.color.flag)($stash_indicator)(ansi reset)'
      }
      if $untracked_indicator != '' {
        $untracked_indicator = $'(ansi $cfg.color.bad)($untracked_indicator)(ansi reset)'
      }
    }

    let f = $'($sparse_checkout_indicator)($unstaged_indicator)($staged_or_no_commit_indicator)($stash_indicator)($untracked_indicator)($short_ahead_behind)'
    let gitstring = $"($bare_indicator)($git_ref)(if $f != '' { $'($state_seperator)($f)' } else { '' })($sparse)($current_wip_git_action)($upstream)($conflict)"

    $'($cfg.prefix)($gitstring)($cfg.suffix)(ansi reset)'
  }
}
