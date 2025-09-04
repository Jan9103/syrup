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
      ) { "|SPARSE" } else { "" }
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
      $current_wip_git_action = "|REBASE"
    } else {
      if ($git_dir | path join 'rebase-apply' | path type) == 'dir' {
        $step = (open --raw ($git_dir | path join 'rebase-apply' 'next') | str trim)
        $total = (open --raw ($git_dir | path join 'rebase-apply' 'last') | str trim)
        if ($git_dir | path join 'rebase-apply' 'rebasing' | path type) == 'file' {
          $git_ref = (open --raw ($git_dir | path join 'rebase-apply' 'head-name') | str trim)
          $current_wip_git_action = '|REBASE'
        } else if ($git_dir | path join 'rebase-apply' 'applying' | path type) == 'file' {
          $current_wip_git_action = '|AM'
        } else {
          $current_wip_git_action = '|AM/REBASE'
        }
      } else if ($git_dir | path join 'MERGE_HEAD' | path type) == 'file' {
        $current_wip_git_action = '|MERGING'
      } else if (try {
        mut todo: string = ''
        if ($git_dir | path join 'CHERRY_PICK_HEAD' | path type) == 'file' {
          $current_wip_git_action = '|CHERRY-PICKING'
          true
        } else if ($git_dir | path join 'REVERT_HEAD' | path type) == 'file' {
          $current_wip_git_action = '|REVERTING'
          true
        } else if (try { $todo = (open --raw ($git_dir | path join 'sequencer' 'todo') | str trim); true } catch { false }) {
          if $todo =~ 'p(ick)? *' {
            $current_wip_git_action = '|CHERRY-PICKING'
          } else if $todo =~ 'revert *' {
            $current_wip_git_action = '|REVERTING'
          }
          true
        } else {
          false
        }
      } catch { false }) {
        # noop
      } else if ($git_dir | path join 'BISECT_LOG' | path type) == 'file' {
        $current_wip_git_action = '|BISECTING'
      }

      if $git_ref != '' {
        # noop
      } else if ($git_dir | path join 'HEAD' | path type) == 'symlink' {
        $git_ref = (^git symbolic-ref HEAD e> (null-device) | str trim)
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
          $head = (^git symbolic-ref HEAD e> (null-device) | str trim)
        }

        if $head == '' {
          $detached = true
          if (try {
            match $cfg.describe_style {
              'contains' => { $git_ref = (^git describe --contains HEAD e> (null-device) | str trim) }
              'branch' => { $git_ref = (^git describe --contains --all HEAD e> (null-device) | str trim) }
              'tag' => { $git_ref = (^git describe --tags HEAD e> (null-device) | str trim) }
              'describe' => { $git_ref = (^git describe HEAD e> (null-device) | str trim) }
              'default' => { $git_ref = (^git describe --tags --exact-match HEAD e> (null-device) | str trim) }
            }
            # for some reason non-0 exit codes only sometimes cause a `try` error
            $env.LAST_EXIT_CODE != '0'
          } catch {
            true
          }) {
            $git_ref = $'($short_sha)...'
          }
          $git_ref = $"\(($git_ref)\)"
        } else {
          $git_ref = $head
        }
      }
    }  # end of $b == ''

    if $step != '' and $total != '' {
      $current_wip_git_action = $'($current_wip_git_action) ($step)/($total)'
    }

    let conflict: string = (if (
      ($cfg.parts.conflict.show)
      and ((try { ^git ls-files --unmerged e> (null-device) } catch { '' }) != '')
    ) {
      '|CONFLICT'
    } else { '' })

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
        $bare_indicator = 'BARE:'
      } else {
        $git_ref = 'GIT_DIR!'
      }
    } else if $is_inside_worktree {
      if $cfg.parts.dirty.show {
        if (try { ^git diff --no-ext-diff --quiet; false } catch { true }) {
          $unstaged_indicator = '*'
        }
        if (try { ^git diff --no-ext-diff --cached --quiet; false } catch { true }) {
          $staged_or_no_commit_indicator = '+'
        }
        if $short_sha == '' and $staged_or_no_commit_indicator == '' {
          $staged_or_no_commit_indicator = '#'
        }
      }  # end dirty

      $stash_indicator = (if (
        ($cfg.parts.stash.show)
        and (try { ^git rev-parse --verify --quiet refs/stash o+e> (null-device); true } catch { false })
      ) { '$' } else { '' })

      if (
        ($cfg.parts.untracked.show)
        and (try { ^git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' o+e> (null-device); true } catch { false })
      ) {
        # for some reason the original '/usr/share/git/git-prompt.sh' only shows this inside of zsh.. idk why
        $untracked_indicator = '%'
      }

      if (
        ($cfg.parts.sparse.compress)
        and (try { ^git config --bool core.sparseCheckout; true } catch { false })
      ) {
        $sparse_checkout_indicator = '?'
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
          [0, 0] => { if $cfg.parts.upstream.verbose { '|u=' } else { $short_ahead_behind = '='; '' } }  # no divergence
          [0, $ahead] => { if $cfg.parts.upstream.verbose { $'|u+($ahead)' } else { $short_ahead_behind = '>'; '' } }  # ahead
          [$behind, 0] => { if $cfg.parts.upstream.verbose { $'|u-($behind)' } else { $short_ahead_behind = '<'; '' } }  # behind
          [$behind, $ahead] => { if $cfg.parts.upstream.verbose { $'|u+($ahead)-($behind)' } else { $short_ahead_behind = '<>'; '' } }  # diverged
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
