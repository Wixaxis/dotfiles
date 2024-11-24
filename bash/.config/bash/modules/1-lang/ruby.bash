export RBENV_ROOT="$XDG_DATA_HOME/rbenv"
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"
export SOLARGRAPH_CACHE="$XDG_CACHE_HOME/solargraph"


eval "$(rbenv init - bash)"
eval "$(rbenv rehash)"
