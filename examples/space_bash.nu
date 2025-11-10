# a port of a bash-prompt i copied and used for years - named after the author
# yes colors change based on the hostname

export-env {
  let hostname = (sys host).hostname
  let seed = ($hostname | hash md5 | str replace --all --regex '[^1234567]+' '')
  let hc1 = ($seed | str substring 0..0)
  let hc2 = ($seed | str substring 1..1)

  $env.SYRUP_PROMPT = {
    'prompt': [
      [
        $"(ansi reset)\e[01;3($hc1)m($env.USER)(ansi reset)@\e[01;3($hc2)m($hostname)(ansi reset): "
        ["pwd"]
      ]
      [
        ['datetime' {'format': $'(ansi yellow)%H:%M:%S'}]
        $"(ansi green)\("
        ['exitstatus' {'show_ok': true, 'format': {'err': '{status}', 'ok': '{status}'}}]
        ['jobcount' {'show_0': true, 'format': ' J{count}'}]
        {|| $' !(history | length)' }
        ')'
        ['gitprompt']
      ]
    ]
  }

  $env.PROMPT_INDICATOR = (if (is-admin) { ' # ' } else { ' $ ' })
  $env.PROMPT_INDICATOR_VI_INSERT = (if (is-admin) { ' # ' } else { ' $ ' })
  $env.PROMPT_INDICATOR_VI_NORMAL = ' : '
  $env.PROMPT_MULTILINE_INDICATOR = ' > '
}

