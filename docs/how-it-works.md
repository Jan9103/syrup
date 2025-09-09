# How it Works

Pseudocode:

```nu
def render_prompt [] {
  let control_job = job spawn {
    wait_for_initial_print
    for finished_section in (job recv) {
      redraw_prompt ($current | replace $placeholder $finished_section)
    }
  }

  $env.SYRUP_PROMPT
  | each {|line|
    $line
    | par-each {|element|
      if (is_asnyc $element) {
        spawn_job {
          render_element $element
          | job send $control_job
        }
        $element.placeholder
      } else {
        render_element $element
      }
    }
    | str join ''
  }
  | str join "\n"
  | print $in
}
```
