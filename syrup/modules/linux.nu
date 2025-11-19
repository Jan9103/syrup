const LOAD_DEFAULT: record = {
  'high_load': 3.0
  'time': 1min  # or 5min or 15min

  'format': {
    'high_load': $'(ansi red) {load}(ansi reset) '
    'low_load': ''
  }
}

export-env {
  $env.SYRUP_PROMPT_MODULES.linux_load = {|cfg|
    let cfg: record = ($LOAD_DEFAULT | merge deep $cfg)
    # use direct since `sys cpu` grabs lots of extra info, making it slower
    let la: list<string> = (open --raw /proc/loadavg | split row ' ')
    let load = (match $cfg.time {
      1min  => { get 0 }
      5min  => { get 1 }
      15min => { get 2 }
      _ => { error make { msg: '[syrup/linux] invalid load time config value' } }
    } | into float)

    { 'load':   $load
      'load1':  $la.0
      'load5':  $la.1
      'load15': $la.2
    } | format pattern (if $load > $cfg.high_load { $cfg.format.high_load } else { $cfg.format.low_load })
  }
}

