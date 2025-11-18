const VENV_DEFAULT: record = {
  'format': {
    'venv': ' {venv_dir_parent_name}'
    'no_venv': ''
  }
}

export-env {
  $env.SYRUP_PROMPT_MODULES.python_venv = {|cfg|
    let cfg: record = ($VENV_DEFAULT | merge deep $cfg)
    if 'VIRTUAL_ENV' not-in $env {
      return $cfg.format.no_venv
    }

    { 'venv_dir_abs': $env.VIRTUAL_ENV
      'venv_dir_name': ($env.VIRTUAL_ENV | path basename)
      'venv_dir_parent_abs': ($env.VIRTUAL_ENV | path dirname)
      'venv_dir_parent_name': ($env.VIRTUAL_ENV | path dirname | path basename)
    } | format pattern $cfg.format.venv
  }
}

