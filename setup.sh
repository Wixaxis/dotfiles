#!/usr/bin/env bash
set -euo pipefail

# Thin shell entrypoint only.
# The metadata-driven setup workflow lives in scripts/dotfiles.rb.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_ruby() {
    local script="$ROOT/scripts/dotfiles.rb"

    if [[ "${DOTFILES_DISTRO:-}" == "omarchy" ]] || {
        [[ -z "${DOTFILES_DISTRO:-}" ]] &&
            [[ -r /etc/os-release ]] &&
            [[ "$(. /etc/os-release && printf '%s' "${ID:-}")" == "omarchy" ]]
    }; then
        script="$ROOT/scripts/omarchy-setup.rb"
    fi

    if command -v mise >/dev/null 2>&1; then
        exec mise exec ruby -- ruby "$script" "$@"
    fi

    if ! command -v ruby >/dev/null 2>&1; then
        echo "ruby is required to run the dotfiles setup." >&2
        exit 1
    fi

    if ! ruby -e 'required = [3, 1]; current = RUBY_VERSION.split(".").first(2).map(&:to_i); exit((current <=> required) >= 0 ? 0 : 1)' >/dev/null 2>&1; then
        echo "ruby >= 3.1 is required to run the dotfiles setup. Install mise or a newer ruby." >&2
        exit 1
    fi

    exec ruby "$script" "$@"
}

if command -v gum >/dev/null 2>&1; then
    gum style --bold --foreground 12 "Dotfiles Setup"
    gum style --foreground 8 "Repo: $ROOT"
fi

run_ruby "$@"
