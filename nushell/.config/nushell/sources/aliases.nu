def lsa [] { ls -a | sort-by modified | reverse }
alias mux = tmuxinator
alias reset = zsh -c 'reset && exit'
alias trash = /opt/homebrew/opt/trash-cli/bin/trash
alias rm = trash
alias mv = mv -i
alias bw_login_shell = scripts bw_login_shell
alias bw_unlock_shell = scripts bw_unlock_shell
alias ensure_unlocked_ssh = scripts ensure_unlocked_ssh
alias ensure_kamal_ready = scripts ensure_kamal_ready
alias qa = scripts qa
alias notes = scripts nvnote
