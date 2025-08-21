export def ansi_compile [] { $in | ruby $"($env.NU_CUSTOM_CONFIG_PATH)/scripts/ruby/ansi_compile.rb" }

export def bw_login_shell [] {
    let bw_status = (bw status | from json | get status)
    match $bw_status {
        "locked" => {
            error make --unspanned { msg: "Bitwarden already authenticated! Use bw_unlock_shell instead!" }
        },
        "unlocked" => {
            error make --unspanned { msg: "Already in authenticated and unlocked bitwarden session!" }
        },
        "unauthenticated" => {
            new_bw_shell (bw login --raw | str trim)
        }
    }
}

export def bw_unlock_shell [] {
    let bw_status = (bw status | from json | get status)
    match $bw_status {
        "locked" => {
            new_bw_shell (bw unlock --raw | str trim)
        },
        "unlocked" => {
            error make --unspanned { msg: "Already in authenticated and unlocked bitwarden session!" }
        },
        "unauthenticated" => {
            error make --unspanned { msg: "Bitwarden not authenticated! Use bw_login_shell instead!" }
        }
    }
}

export def new_bw_shell [BW_SESSION: string] {
    if ($env.BW_SESSION? | is-not-empty) {
        error make --unspanned { msg: "Already running in BW_SESSION set environment" }
    }

    if ($BW_SESSION | is-empty) {
        error make --unspanned { msg: "Couldn't get BW_SESSION token from login or unlock" }
    }
    with-env { BW_SESSION: ($BW_SESSION) } { nu }
}


export def ensure_unlocked_ssh [] {
    ssh-add --apple-load-keychain err> /dev/null
    let status = (ssh-add -l err> /dev/null | complete)
    if ($status.exit_code != 0) or (not ($status.stdout | str contains "id_ed25519")) {
        ssh-add --apple-use-keychain ~/.ssh/id_ed25519 err> /dev/null
    }
}

export def ensure_kamal_ready [] {
    let bw_status = (bw status | from json | get status)
    match $bw_status {
        "locked" => {
            error make --unspanned { msg: "Bitwarden locked! Use bw_unlock_shell first!" }
        },
        "unauthenticated" => {
            error make --unspanned { msg: "Bitwarden not authenticated! Use bw_login_shell first!" }
        }
    }
    if ($env.BW_SESSION? | is-empty) {
        error make --unspanned { msg: "No BW_SESSION env set! Exit session and reauthenticate/unlock first!" }
    }
    ensure_unlocked_ssh
}


export def qa [host_number: int, ...rest: string] {
    if not (pwd | str contains 'activenow') { error make --unspanned { msg: "Not in activenow rails project!" }}
    ensure_kamal_ready
    with-env { BW_SESSION: $env.BW_SESSION, QA_HOST_NAME: ($"qa-" + $"($host_number)") } { kamal ...$rest }
}

export def nvnote [...params: string] {
    with-env { NVIM_APPNAME: 'nvnote' } { nvim ...$params }
}
