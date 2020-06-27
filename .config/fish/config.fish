# -*- mode: fish -*-

set FISH_CONFIG_DIR $HOME/.config/fish

# for non-interactive shell
if [ $TERM = "dumb" ] || [ $TERM = "eterm-color" ]
    set -x SHELL (which bash)
    exec bash
end

# powerline
if [ -f $FISH_CONFIG_DIR/functions/powerline-setup.fish ]
    powerline-setup
    set -g theme_color_scheme solarized
end

# setup fisherman
if not [ -f $FISH_CONFIG_DIR/functions/fisher.fish ]
    echo "==> Fisherman not found. Installing..."
    curl -Lo $FISH_CONFIG_DIR/functions/fisher.fish --create-dirs git.io/fisher
    fisher
end

# enviroment variables
source $HOME/.envvars
set -gx GHQ_ROOT $HOME/src

# Golang
set -gx GOPATH $HOME/.go
function add_path
    set -l maybe_path $argv[1]
    if not contains $maybe_path $PATH && [ -d $maybe_path ]
        set -gx PATH $maybe_path $PATH
    end
end
add_path $GOPATH/bin

# Python
set -gx PYENV_ROOT $HOME/.pyenv
add_path $PYENV_ROOT/bin
if which pyenv >/dev/null ^/dev/null
    pyenv init - | source
    add_path $HOME/.poetry/bin
end

# Ruby
if which ruby >/dev/null ^/dev/null
    add_path (ruby -e 'puts Gem.user_dir')/bin
end

# PATH
add_path $HOME/.local/bin
add_path $HOME/local/bin
add_path $HOME/bin

# No Greeting
set fish_greeting

# Setting peco
function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
end

# for Gentoo
if [ "$DISTRIB_ID""x" = "gentoox" ]
    gentoo-mode
end

# alias
alias g "git"

# for experiments
add_path $HOME/src/github.com/de9uch1/mlenv/bin
add_path $HOME/src/github.com/de9uch1/MiniBatch/bin
add_path $HOME/src/github.com/de9uch1/Xplorer/bin

if which xp ^/dev/null > /dev/null && [ -n $FILTER ]
    function tl
        set -l name (xp -n | eval $FILTER ^/dev/null)
        if [ -n "$name" ]
            less (xp -p logs $name)/train.log
        end
    end
    function tt
        set -l name (xp -n | eval $FILTER ^/dev/null)
        if [ -n "$name" ]
            tail -f (xp -p logs $name)/train.log
        end
    end
end
