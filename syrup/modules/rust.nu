use ../util.nu [find_in_pardirs]

const VERSION_DEFAULT: record = {
  'format': {
    'in_cargo_dir': $' (ansi red) {version}(ansi reset)'
    'otherwise': ''
  }
}

export-env {
  $env.SYRUP_PROMPT_MODULES.rust_version = {|cfg|
    let cfg: record = ($VERSION_DEFAULT | merge deep $cfg)
    let res: string = (^rustc --version)
    ($res | parse 'rustc {version} ({hash} {date})').0
    | insert year {|i| $i.date | split row '-' | first }
    | format pattern (
      if ($env.PWD | find_in_pardirs 'Cargo.toml') == null {
        $cfg.format.otherwise
      } else {
        $cfg.format.in_cargo_dir
      }
    )
  }
}
