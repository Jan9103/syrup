use ../util.nu [find_in_pardirs trip_all_errors]
use std/util [null-device]

const GIT_BRANCH_DEFAULT: record = {
  'format': {
    'branch': $' (ansi green){branch}(ansi reset)'
    'detached': $' (ansi yellow){short_sha}(ansi reset)'
    'not_git': ''
  }
}

const PWD_DEFAULT: record = {
  'prefix_element': {
    'default': ''  # empty string causes a seperator
    'home': '~'
    'git': ''
    'shortened': '…'
  }
  'format': {
    'default': $'(ansi blue){path}(ansi reset)'
    'home': $'(ansi cyan){path}(ansi reset)'
    'git': $'(ansi green){path}(ansi reset)'
    'shortened': $'(ansi yellow){path}(ansi reset)'

    'element': '{element}'
  }
  'seperator': '/'
  'git': true
  'home': true
  'max_elements': 5
}

const OVERLAY_DEFAULT: record = {
  'seperator': '>'
  'ignore': ['zero']
  'limit': null
  'format': $" (ansi green){overlays}(ansi reset)"
}

const EXITSTATUS_DEFAULT: record = {
  'show_ok': false
  'format': {
    'err': $' (ansi red)x{status}(ansi reset)'
    'ok': $' (ansi green)x{status}(ansi reset)'
  }
}

const DATETIME_DEFAULT: record = {
  'format': '%H:%M:%S'  # `format date` format
}

const JOBCOUNT_DEFAULT: record = {
  'show_0': false
  'format': ' 󱇫 {count}'
}

const CMD_DURATION_DEFAULT: record = {
  'min': 5sec
  'format': $' (ansi red){duration}(ansi reset)'
}

export-env {
  $env.SYRUP_PROMPT_MODULES = {
    "overlay": {|cfg|
      let cfg = ($OVERLAY_DEFAULT | merge deep $cfg)
      overlay list
      | if ($in | describe) =~ '^table' { where $it.active == true | get name } else { $in }  # https://www.nushell.sh/blog/2025-09-02-nushell_0_107_0.html#add-active-column-to-overlay-list-16125-toc
      | where $it not-in $cfg.ignore
      | if $cfg.limit != null { last $cfg.limit } else { $in }
      | str join ($cfg.seperator? | default '>')
      | if ($in | is-empty) { $in } else {
        {'overlays': $in}
        | format pattern $cfg.format
      }
    }

    "pwd": {|cfg|
      let cfg: record = ($PWD_DEFAULT | merge deep $cfg)
      mut bdir: string = ''
      mut type: string = 'default'

      if $cfg.home {
        if ($env.PWD | str starts-with $nu.home-path) {
          $type = 'home'
          $bdir = $nu.home-path
        }
      }

      if $cfg.git {
        let gbdir = (
          $env.PWD | find_in_pardirs '.git'
          | if $in == null { null } else { $in | path dirname }
        )
        if $gbdir != null and ($gbdir | str length) > ($bdir | str length) {
          $type = 'git'
          $bdir = $gbdir
        }
      }

      $env.PWD | str replace $bdir '' | str trim --left --char '/'
      | path split
      | if $cfg.max_elements != null and ($in | length) > $cfg.max_elements {
        $type = 'shortened'
        $in | last $cfg.max_elements
      } else { $in }
      | if ($cfg.prefix_element | get $type) == null { $in } else { prepend ($cfg.prefix_element | get $type) }
      | wrap 'element'
      | format pattern $cfg.format.element
      | str join $cfg.seperator
      | {'path': $in}
      | format pattern ($cfg.format | get $type)
    }

    "exitstatus": {|cfg|
      let cfg = ($EXITSTATUS_DEFAULT | merge deep $cfg)
      if not $cfg.show_ok and $env._SYRUP_PROMPT_TMP.LAST_EXIT_CODE == 0 { return ''; }
      {'status': $env._SYRUP_PROMPT_TMP.LAST_EXIT_CODE}
      | format pattern (if $env._SYRUP_PROMPT_TMP.LAST_EXIT_CODE == 0 { $cfg.format.ok } else { $cfg.format.err })
    }

    "datetime": {|cfg|
      let cfg = ($DATETIME_DEFAULT | merge deep $cfg)
      date now | format date $cfg.format
    }

    "jobcount": {|cfg|
      let cfg = ($JOBCOUNT_DEFAULT | merge deep $cfg)
      let count: int = (
        job list
        | where not ($it.tag | str starts-with 'syrup::sojourn:')
        | length
      )
      if $count == 0 and not $cfg.show_0 { return '' }
      {'count': $count}
      | format pattern $cfg.format
    }

    'cmd_duration': {|cfg|
      let cfg = ($CMD_DURATION_DEFAULT | merge deep $cfg)
      if $env._SYRUP_PROMPT_TMP.CMD_DURATION_MS > $cfg.min {
        {'duration': $env._SYRUP_PROMPT_TMP.CMD_DURATION_MS}
        | format pattern $cfg.format
      } else {
        ''
      }
    }

    'git_branch': {|cfg|
      let cfg = ($DATETIME_DEFAULT | merge deep $cfg)

      let branch: string = (try { ^git branch --show-current | str trim } catch {
        return ($cfg.format.not_git)
      })
      if $branch == '' {
        # detached HEAD (rebase/..)
        { 'short_sha': (^git rev-parse --short HEAD | str trim)
        } | format pattern $cfg.format.detached
      } else {
        { 'branch': $branch
        } | format pattern $cfg.format.branch
      }
    }
  }

}
