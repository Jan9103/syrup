use ./util.nu [find_in_pardirs, trip_all_errors]

const DEFAULT_CFG = {
  "prompt": [
    []  # empty line
    [
      ["pwd" {} {color: {admin: "red"}}]
      ['git_branch']
      ["overlay"]
      ["jobcount"]
      ['cmd_duration']
    ]
    [
      ["exitstatus"]
    ]  # + the indicator from $env.PROMPT_INDICATOR
  ]
}

export-env {
  source-env ./modules/basic.nu

  $env.config.hooks.pre_execution = (
    $env.config.hooks.pre_execution | append {||
      # prevent further progressive rendering
      for job in (job list | where ($it.tag? | default '' | str starts-with 'syrup::sojourn:')) {
        job kill $job.id
      }
    }
  )

  $env.SYRUP_PROMPT = ($env.SYRUP_PROMPT? | default $DEFAULT_CFG)
  $env.PROMPT_COMMAND_RIGHT = {||
    try {
      [($env.SYRUP_PROMPT?.right_prompt? | default [])] | render_prompt --right
    } catch {|err|
      print $"\e[s\e[H(ansi red)=== SYRUP_PROMPT ERROR: ===\n($err)\n(ansi red)=== END OF ERROR ===\e[u"
      "ERR"
    }
  }
  $env.PROMPT_COMMAND = {||
    try {
      $env.SYRUP_PROMPT.prompt | render_prompt
    } catch {|err|
      $"\n\n(ansi red)=== SYRUP_PROMPT ERROR: ===\n($err)\n(ansi red)=== END OF ERROR ===\n\nPROMPT ERROR > "
    }
  }
}

def apply_modifier [cfg: record]: string -> string {
  mut res: string = $in
  for $c in ($cfg.color? | default {} | transpose k v) {
    # mut does not work with match..
    if $c.k == 'admin' and (is-admin) {
      $res = $'(ansi $c.v)($res | ansi strip)'
    } else if $c.k == "color" {
      $res = $'(ansi $c.v)($res | ansi strip)'
    } else if $c.k == 'exitcode' {
      if ('ok' in $c.v) and $env._SYRUP_PROMPT_TMP.LAST_EXIT_CODE == 0 {
        $'(ansi $c.v.ok)($res | ansi strip)'
      } else if ('err' in $c.v) and $env._SYRUP_PROMPT_TMP.LAST_EXIT_CODE != 0 {
        $'(ansi $c.v.err)($res | ansi strip)'
      }
    }
  }
  for $c in ($cfg.custom? | default []) {
    $res = ($res | do $c)
  }
  $res
}

def render_prompt [--right]: list<list<any>> -> string {
  let prompt_cfg = $in

  let supports_last_line_async = false;
  # let supports_last_line_async = (version).is_heretic_nu? == true;

  if not $supports_last_line_async and ($prompt_cfg | last | any {|i| ($i | describe) =~ 'record|table' and $i.2?.async? != null }) {
    return "SYRUP: ERROR: async cannot be used in the last line of a prompt\n> "
  }
  $env.sojourn_mid = if ($prompt_cfg | length) > 1 {
    job spawn --tag 'syrup::sojourn: manager' {||
      let msg = (job recv --tag 1)
      let pattern: list<string> = $msg.pattern
      let placeholders: record = $msg.placeholders
      mut data: record = {}

      while ($data | transpose | length) != ($placeholders | transpose | length) {
        let msg = (job recv)
        if 'error' in $msg { print --no-newline $"\e[s\e[1F\e[K($msg.error)\e[u"; return }
        $data = ($data | insert $msg.key $msg.data)
        for line_no in 0..<($pattern | length) {
          let p = ($pattern | get $line_no)
          if ($p | str contains $msg.key) {
            let l = (
              $placeholders
              | merge $data
              | transpose k v
              | reduce --fold $p {|it,acc| $acc | str replace $'{($it.k)}' $it.v}
            )
            let up: int = (($pattern | length) - $line_no) - 2
            print --no-newline $"\e[s\e[($up)F\e[K($l)\e[u"
          }
        }
      }
    }
  } else { -1 }

  $env._SYRUP_PROMPT_TMP = (
    $env
    | select LAST_EXIT_CODE CMD_DURATION_MS
    | update CMD_DURATION_MS {
      if $in =~ '^0' { '0' } else { $in }  # get rid of the easter-egg
      | into int
      | into duration --unit ms
    }
  )
  let res: record<ph: table<eid: string, pht: string>, p: list<string>> = (
    $prompt_cfg
    | each {|line|
      $line
      | par-each --keep-order {|element|
        match ($element | describe | split row '<' --number 2 | first) {
          'closure' => { do $element | {'p': $in} }
          'string' => { $element | {'p': $in} }
          'list' => {
            let renderer = ($env.SYRUP_PROMPT_MODULES | transpose k v | where $it.k == $element.0).0?.v?
            if $renderer == null {
              error make {msg: $"ERROR: UNKNOWN ELEMENT: ($element.0)"}
            } else if $element.2?.async? != null {
              let eid = (random int)
              let pht = ($element.2.async.placeholder? | default '')
              job spawn --tag 'syrup::sojourn: worker' {||
                try {
                  do $renderer ($element.1? | default {})
                  | apply_modifier ($element.2? | default {} | reject 'async')
                  | {'key': $'sojourn($eid)', 'data': $in}
                } catch {|err|
                  let tf = (mktemp)
                  $"($err.rendered)\n\n($err.json)"
                  | save --raw --force $tf
                  {'error': $'ERROR: open --raw ($tf | to json --raw)'}
                }
                | try { job send $env.sojourn_mid }
              }
              {
                'p': $'{sojourn($eid)}'
                'ph': {'eid': $eid, 'pht': $pht}
              }
            } else {
              do $renderer ($element.1? | default {})
              | apply_modifier ($element.2? | default {})
              | {'p': $in}
            }
          }
        }
      }
      | trip_all_errors
      | {'ph': ($in | each { get ph? } | compact ), 'p': ($in.p | str join '')}
    }
    | trip_all_errors
    | {'ph': ($in.ph | flatten), 'p': $in.p}
  )
  
  let pattern = $res.p
  let placeholders = ($res.ph | reduce --fold {} {|it,acc| $acc | insert $'sojourn($it.eid)' $it.pht })
  let result: list<string> = (
    $pattern
    | each {|line|
      $placeholders
      | transpose k v
      | reduce --fold $line {|it,acc| $acc | str replace $'{($it.k)}' $it.v}
    }
  )

  if not $right and not $supports_last_line_async and ($result | length) > 1 {
    $result
    | drop 1
    | str join "\n"
    | print $in
  }

  if $env.sojourn_mid != -1 {
    {
      'pattern': $pattern
      'placeholders': $placeholders
    } | try { job send $env.sojourn_mid --tag 1 }
  }

  if $supports_last_line_async {
    $result | str join "\n"
  } else {
    $result | last
  }
  # | $"\e[?25h($in)"  # some programs forget to disable "hide cursor" mode
}
