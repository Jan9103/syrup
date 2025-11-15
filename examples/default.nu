export-env {
  $env.SYRUP_PROMPT = {
    "prompt": [
      []  # empty line
      [
        ["pwd" {} {color: {admin: "red"}}]
        ['git_branch']
        ["overlay"]
        ["jobcount"]
        ['cmd_duration']
      ]
      [
        ["exitstatus"]
      ]  # + the indicator from $env.PROMPT_INDICATOR
    ]
  }
}
