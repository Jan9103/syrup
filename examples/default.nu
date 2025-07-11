$env.SYRUP_PROMPT = {
  "prompt": [
    []  # empty line
    [
      ["pwd" {} {color: {admin: "red"}}]
      ["overlay"]
      ["jobcount"]
      ['cmd_duration']
    ]
    [
      ["exitstatus"]
    ]  # + the indicator from $env.PROMPT_INDICATOR
  ]
}
