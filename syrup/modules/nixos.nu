const SHELL_DEFAULT: record = {
  'format': {
    'shell': '󱄅 {purity}'
    'no_shell': ''

    'purity': {
      'impure': 'impure'
      'pure': 'pure'
    }
  }
}

export-env {
  $env.SYRUP_PROMPT_MODULES.nix_shell = {|cfg|
    let cfg: record = ($SHELL_DEFAULT | merge deep $cfg)
    if 'IN_NIX_SHELL' in $env {
      { 'purity': $env.IN_NIX_SHELL
      } | format pattern $cfg.format.shell
    } else {
      $cfg.format.no_shell
    }
  }
}


