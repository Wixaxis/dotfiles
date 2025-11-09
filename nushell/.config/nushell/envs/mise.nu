let mise_env = (^env -i (which 'mise' | first | get 'path') activate nu)
let module_path = ($env.NU_CUSTOM_CONFIG_PATH | path join 'modules' 'mise.nu')

if not ($module_path | path exists) or ((open $module_path) != $mise_env) {
    $mise_env | save $module_path --force
}
