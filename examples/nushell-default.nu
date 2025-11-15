# this emulates the default prompt nushell ships with.

export-env {
  let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
  let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })

  $env.SYRUP_PROMPT = {
    "prompt": [
      [["pwd" {
        'git': false  # disable shortening based on git-dirs
        'max_elements': null  # disable shortening of long paths
        'prefix_element': {'default': ''}  # remove prefix for root-directory
        'format': {  # change colors
          'default': $'($path_color){path}(ansi reset)'
          'home': $'($path_color){path}(ansi reset)'
        }
        'seperator': $'($separator_color)(char path_sep)($path_color)'
      }]]  # + the indicator from $env.PROMPT_INDICATOR
    ]
    "right_prompt": [
      ['exitstatus' {'format': {'err': $'(ansi red_bold){status}(ansi reset)'}}]

      ['datetime' {'format': $' (ansi magenta)%x %X(ansi reset)'} {'custom': {||
        # nu has some custom syntax-highlight for the date
        str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)"
        | str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}"
      }}]
    ]
  }
}
