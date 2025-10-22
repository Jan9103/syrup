const LINE_ANSI: string = $'(ansi reset)(ansi cyan)'
const ERR_ANSI: string = $'(ansi reset)(ansi red_bold)'
const OK_ANSI: string = $'(ansi reset)(ansi green)'
const MEH_ANSI: string = $'(ansi reset)(ansi yellow)'

export-env {
  $env.SYRUP_PROMPT = {
    'prompt': [
      [
        $'($LINE_ANSI)╭─<'
        ['pwd']
        ['git_branch' {
          'format': {
            'branch': $'($LINE_ANSI)>─<($OK_ANSI){branch}'
            'detached': $'($LINE_ANSI)>─<($MEH_ANSI){short_sha}'
          }
        }]
        $'($LINE_ANSI)>─╴'
      ]
      [
        $'($LINE_ANSI)╰─'
        ['exitstatus' {'format': {'err': $'<($ERR_ANSI){status}($LINE_ANSI)>─'}}]
      ]
    ]
  }
  $env.PROMPT_INDICATOR = '> '
  $env.PROMPT_INDICATOR_VI_INSERT = '> '
  $env.PROMPT_INDICATOR_VI_NORMAL = '╴ '
  $env.PROMPT_MULTILINE_INDICATOR = '┆ '
}
