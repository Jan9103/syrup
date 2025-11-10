use ../util.nu [null_device]

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

export-env {
  $env.SYRUP_PROMPT_MODULES.mpc = {|cfg|
    let cfg: record = ($MPC_DEFAULT | merge deep $cfg)
    let mrl = (try { ^mpc e> $null_device | lines } catch { return '' })
    let l1 = ($mrl | parse -r '\[(?P<status>paused|playing)\] +#\d+/\d+ +(?P<now>[0-9:]+)/(?P<total>[0-9:]+)').0?
    let l2 = ($mrl | parse -r 'volume: (?P<volume>\d+)% +repeat: (?P<repeat>on|off) +random: (?P<random>on|off) +single: (?P<single>on|off) +consume: (?P<consume>on|off)').0?
    if $l1 == null or $l2 == null { return '' }

    {
      'repeat': ($cfg.symbols.repeat | get (($l2.repeat == 'on') | into string))
      'random': ($cfg.symbols.random | get (($l2.random == 'on') | into string))
      'single': ($cfg.symbols.single | get (($l2.single == 'on') | into string))
      'consume': ($cfg.symbols.consume | get (($l2.consume == 'on') | into string))
      'mode': (if ($l2.single == 'on') { $cfg.symbols.mode.single } else if ($l2.random == 'on') { $cfg.symbols.mode.random } else if ($l2.repeat == 'on') { $cfg.symbols.mode.repeat } else { $cfg.symbols.mode.other })
      'short_duration_now': $l1.now
      'short_duration_total': $l1.total
      'volume_percent': ($l2.volume | into int)
      'current_time': ($l1.now | parse_mpc_duration)
      'total_time': ($l1.total | parse_mpc_duration)
      'title': $mrl.0
    }
    | format pattern (if ($l1.status == 'playing') { $cfg.format.playing } else { $cfg.format.paused })
  }
}
