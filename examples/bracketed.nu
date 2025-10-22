export-env {
  $env.SYRUP_PROMPT = {
    'prompt': [
      [
        {|| if (is-admin) { $"[(ansi red)root(ansi reset)]" } else { "" } }
        ["pwd"]
        " "
        ['git_branch' {'format': {
          'branch':   $'[(ansi purple) {branch}(ansi reset)]'
          'detached': $'[(ansi purple) {short_sha}(ansi reset)]'
        }}]
        ['cmd_duration' {'format': $'[⏱️ (ansi yellow){duration}(ansi reset)]'}]
        ['jobcount' {'format': '[󱇫 {count}]'}]
      ]

      [["exitstatus"]]  # + the indicator from $env.PROMPT_INDICATOR
    ]
  }
}
