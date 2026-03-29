@_default:
  just --choose

list:
  ./setup.sh --list

setup *ARGS:
  ./setup.sh {{ARGS}}

check *ARGS:
  ./setup.sh --check {{ARGS}}

dry-run *ARGS:
  ./setup.sh --dry-run {{ARGS}}

smoke:
  bash scripts/tests/smoke.sh

ruby-syntax:
  if command -v mise >/dev/null 2>&1; then mise exec ruby -- ruby -c scripts/dotfiles.rb; else ruby -c scripts/dotfiles.rb; fi

shellcheck:
  shellcheck setup.sh stow-platform.sh check-installed-packages.sh scripts/package-run.sh scripts/tests/smoke.sh packages/*/*/*.sh
