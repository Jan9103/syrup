# Mpc Module

Requirements:
* [mpc](https://www.musicpd.org/clients/mpc/) (used as CLI interface to get the information)

## Configuration

```nu
const DEFAULT = {
  'format': {
    'playing': ' 󰝚 {title} ({volume_percent}% {short_duration_now}/{short_duration_total} {mode})'
    # to make not show it if nothing is playing just set "paused" to ""
    'paused': ' 󰝛 {title}'
  }
  'symbols': {  # symbols to be used within the formatting
    'mode': {  # one of these gets selected for the "mode" placeholder
      'single': '󰑘 '
      'random': ' '
      'repeat': '󰕇 '
      'other': '󰒞 '
    }
    'random':  {'true': ' ', 'false': ''}
    'repeat':  {'true': '󰕇 ', 'false': ''}
    'single':  {'true': '󰑘 ', 'false': ''}
    'consume': {'true': ' ', 'false': ''}
  }
}
```

### Available segments

* `title` (usually both artist and title, but can also be the filename, etc - whatever `mpc` decides to show)
* playtime / duration:
  * `current_time` (nu's duration formatting for how long it has already played)
  * `total_time` (nu's duration formatting for how long it is in total)
  * `short_duration_now` (`1:12` format for how long it has already played)
  * `short_duration_total` (`1:12` format for how long the song is)
* `volume_percent` (just a number)
* playback mode / settings:
  * `mode` (only shows the most relevant setting)
  * `repeat` (repeat the que once the end is reached)
  * `random` (shuffle the playback order)
  * `single` (repeat a single song endlessly)
  * `consume` (mpc's word for "remove from que after playing")
