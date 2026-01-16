export-env {
  
  $env.MISE_SHELL = "nu"
  let mise_hook = {
    condition: { "MISE_SHELL" in $env }
    code: { mise_hook }
  }
  add-hook hooks.pre_prompt $mise_hook
  add-hook hooks.env_change.PWD $mise_hook
}

def --env add-hook [field: cell-path new_hook: any] {
  let field = $field | split cell-path | update optional true | into cell-path
  let old_config = $env.config? | default {}
  let old_hooks = $old_config | get $field | default []
  $env.config = ($old_config | upsert $field ($old_hooks ++ [$new_hook]))
}

def "parse vars" [] {
  $in | from csv --noheaders --no-infer | rename 'op' 'name' 'value'
}

# Detect mise path based on platform
def "get mise path" [] {
  # Check macOS Homebrew path first
  if ("/opt/homebrew/bin/mise" | path exists) {
    "/opt/homebrew/bin/mise"
  } else if ("/usr/sbin/mise" | path exists) {
    "/usr/sbin/mise"
  } else if ("/usr/bin/mise" | path exists) {
    "/usr/bin/mise"
  } else {
    # Fallback to PATH
    "mise"
  }
}

export def --env --wrapped main [command?: string, --help, ...rest: string] {
  let commands = ["deactivate", "shell", "sh"]
  let mise_bin = (get mise path)

  if ($command == null) {
    ^$mise_bin
  } else if ($command == "activate") {
    $env.MISE_SHELL = "nu"
  } else if ($command in $commands) {
    ^$mise_bin $command ...$rest
    | parse vars
    | update-env
  } else {
    ^$mise_bin $command ...$rest
  }
}

def --env "update-env" [] {
  for $var in $in {
    if $var.op == "set" {
      if ($var.name | str upcase) == 'PATH' {
        $env.PATH = ($var.value | split row (char esep))
      } else {
        load-env {($var.name): $var.value}
      }
    } else if $var.op == "hide" {
      hide-env $var.name
    }
  }
}

def --env mise_hook [] {
  let mise_bin = (get mise path)
  ^$mise_bin hook-env -s nu
    | parse vars
    | update-env
}
