# The default prompt, but with more stuff
# 
# used extra modules (require manual import):
# * gitprompt

export-env {
  $env.SYRUP_PROMPT = {
    "prompt": [
      []  # empty line
      [
        ["pwd" {} {color: {admin: "red"}}]
        ["gitprompt" {'parts': {
          'conflict': {'show': true}
          'dirty': {'show': true}
          'untracked': {'show': true}
          'upstream': {'show': true}
        }}]
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
