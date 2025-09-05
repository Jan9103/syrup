# a reimplementation of <https://starship.rs/presets/pastel-powerline>
#
# required modules:
# * gitprompt

const white  = '#ffffff'
const purple = '#9a348e'
const salmon = '#da627d'
const yellow = '#fca17d'
const cyan   = '#06969a'

export-env {
  $env.SYRUP_PROMPT = {
    'prompt': [
      [
        # username
        $"(ansi --escape {fg: $purple})(ansi --escape {bg: $purple fg: $white})($env.USER) (ansi --escape {bg: $salmon fg: $purple})(ansi --escape {bg: $salmon, fg: $white}) "
        # path
        ['pwd' {
          'format': {
            'default': '{path}'
            'home': '{path}'
            'git': '{path}'
            'shortened': '{path}'
          }
          'seperator': '\'
        }]
        # git
        $' (ansi --escape {fg: $salmon bg: $yellow})(ansi --escape {bg: $yellow fg: $white})'
        ['git_branch' {
          'format': {
            'branch':   '  {branch} '
            'detached': '  {short_sha} '
            'not_git':  ''
          }
        }]
        # time
        $'(ansi --escape {fg: $yellow bg: $cyan})(ansi --escape {bg: $cyan fg: $white})'
        ['datetime' {'format': ' ♥ %H:%M '}]
        $'(ansi reset)(ansi --escape {fg: $cyan})(ansi reset) '
      ]
    ]
  }

  $env.PROMPT_INDICATOR = ''
  $env.PROMPT_INDICATOR_VI_INSERT = ''
  $env.PROMPT_INDICATOR_VI_NORMAL = ''
}
