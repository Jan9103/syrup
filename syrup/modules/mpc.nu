const MPC_DEFAULT: record = {
  'format': {
    'playing': ' 󰝚 {title} ({volume_percent}% {short_duration_now}/{short_duration_total} {mode})'
    'paused': ' 󰝛 {title}'
  }
  'symbols': {
    'mode': {
      'single': '󰑘 '
      'random': ' '
      'repeat': '󰕇 '
      'other': '󰒞 '
    }
    'random':  {'true': ' ', 'false': ''}
    'repeat':  {'true': '󰕇 ', 'false': ''}
    'single':  {'true': '󰑘 ', 'false': ''}
    'consume': {'true': ' ', 'false': ''}
  }
}

def parse_mpc_duration []: string -> duration {
  split row ':'
  | reverse
  | zip ['sec' 'min' 'hr']  # zip throws away extras -> with reverse both min:sec and hr:min:sec are supported
  | each { str join '' }
  | str join ' '
  | into duration
}

def parse_mpc_std_response []: string -> record {
  let mrl: list<string> = ($in | lines)
  let l1 = ($mrl | parse -r '\[(?P<status>paused|playing)\] +#\d+/\d+ +(?P<now>[0-9:]+)/(?P<total>[0-9:]+)').0?
  let l2 = ($mrl | parse -r 'volume: (?P<volume>\d+)% +repeat: (?P<repeat>on|off) +random: (?P<random>on|off) +single: (?P<single>on|off) +consume: (?P<consume>on|off)').0?

  if $l1 == null or $l2 == null {
    return {}
  }

  {
    'title': $mrl.0
    'is_playing': ($l1.status == 'playing')
    'current_time': ($l1.now | parse_mpc_duration)
    'total_time': ($l1.total | parse_mpc_duration)
    'volume_percent': ($l2.volume | into int)
    'repeat': ($l2.repeat == 'on')
    'random': ($l2.random == 'on')
    'single': ($l2.single == 'on')
    'consume': ($l2.consume == 'on')
    'short_duration_now': $l1.now
    'short_duration_total': $l1.total
  }
}

export-env {
  # source-env ../mod.nu  # avoid load-order problems
  $env.SYRUP_PROMPT_MODULES.mpc = {|cfg|
    let cfg: record = ($MPC_DEFAULT | merge deep $cfg)
    let mpc_resp = (try { ^mpc } catch { return '' })
    let resp: record = (^mpc | parse_mpc_std_response)
    if $resp == {} { return '' }
    $resp
    | merge {
      'repeat': ($cfg.symbols.repeat | get ($resp.repeat | into string))
      'random': ($cfg.symbols.random | get ($resp.random | into string))
      'single': ($cfg.symbols.single | get ($resp.single | into string))
      'consume': ($cfg.symbols.consume | get ($resp.consume | into string))
      'mode': (if $resp.single { $cfg.symbols.mode.single } else if $resp.random { $cfg.symbols.mode.random } else if $resp.repeat { $cfg.symbols.mode.repeat } else { $cfg.symbols.mode.other })
    }
    | format pattern (if $resp.is_playing { $cfg.format.playing } else { $cfg.format.paused })
  }
}
