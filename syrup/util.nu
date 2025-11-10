# these are extracts from other projects.
# they are hardcoded since package managers are not yet widespread and
# installation becomes unnecesarely complex otherwise.

#######################################################################

# this is a extract of https://github.com/Jan9103/nutils (MIT License)

export def list_pardirs []: string -> list<string> {
  let parts = ($in | path split)
  0..(($parts | length) - 1)
  | each {|i| $parts | slice 0..($i) | path join}
}

export def find_in_pardirs [name: string]: string -> any {
  for parent in ($in | list_pardirs) {
    if ($parent | path join $name | path exists) {
      return $parent
    }
  }
  return null
}

export def trip_all_errors []: any -> any {
  let input = $in
  let d = ($input | describe | split row ' ' | first | split row '<' | first)
  if $d in ['list' 'table'] {
    for i in $input {
      $i | trip_all_errors
    }
  } else if $d == 'record' {
    for i in ($input | transpose k v) {
      $i.k | trip_all_errors
      $i.v | trip_all_errors
    }
  }
  $input
}

#######################################################################

# this is a extract of nu-std https://github.com/nushell/nushell (MIT LICENSE)

export const null_device = if $nu.os-info.name == "windows" {
  '\\.\NUL'
} else {
  '/dev/null'
}
