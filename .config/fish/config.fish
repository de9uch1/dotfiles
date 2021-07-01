# -*- mode: fish -*-

set FISH_CONFIG_DIR $HOME/.config/fish

# for non-interactive shell
# if [ $TERM = "dumb" ] || [ $TERM = "eterm-color" ]
#     set -x SHELL (which bash)
#     exec bash
# end

### Theme: Dracula
if not [ -f $FISH_CONFIG_DIR/conf.d/dracula.fish ]
    mkdir -p $FISH_CONFIG_DIR/conf.d
    curl -o $FISH_CONFIG_DIR/conf.d/dracula.fish \
        "https://raw.githubusercontent.com/dracula/fish/master/conf.d/dracula.fish"
end

### Greeting
set fish_greeting

### Prompt: Starship
if command -v starship >/dev/null
    starship init fish | source
end

### Plugin Manager: Fisher
set FISHER_INITIALIZED "$FISH_CONFIG_DIR/.fisher"
if not [ -f $FISHER_INITIALIZED ]
    echo "==> Fisher not found. Installing..."
    touch $FISHER_INITIALIZED
    curl -sL https://git.io/fisher | source; and fisher update
end

#### enhancd
bind --erase \ef
# set -g ENHANCD_HOOK_AFTER_CD "pwd; ls"

### Enviroment Variables
function reload_profile
    bass source $HOME/.config/profile
end
if [ -z "$LOADED_PROFILE" ]; and type -q bass
    reload_profile
end

### Functions
function add_path
    set -l maybe_path $argv[1]
    if not contains $maybe_path $PATH
        set -gx PATH $maybe_path $PATH
    end
end

function err
    echo "$argv"
    return -1
end

#### dotfiles
function dots
    set -l usage "usage: dots [u]"
    if [ (count $argv) != 1 ]
        err "$usage" || return -1
    end
    switch $argv[1]
        case u up update upgrade pull
            pushd ~/.dotfiles
            git pull
            make link
            popd
        case *
            err "$usage" || return -1
    end
end

### Gentoo System
if [ "{$DISTRIB_ID}x" = "gentoox" ]
    # app-portage/portage-utils
    alias lastsync 'qlop -s | tail -n1'
    alias qtime 'qlop -tv'

    # app-portage/flaggie
    function acckw
        switch $argv[1]
            case a
                sudo flaggie $argv[2] '+kw::~amd64'
            case d
                sudo flaggie $argv[2] '-kw::~amd64'
            case r
                sudo flaggie $argv[2] '%kw::~amd64'
            case v
                sudo flaggie $argv[2] '?kw::~amd64'
            case ''
                return 1
            case '*'
                return 1
        end
    end
end

### Python
if command -v pyenv >/dev/null
    set -gx PYENV_SHELL fish
    source "$PYENV_ROOT/libexec/../completions/pyenv.fish"
    command pyenv rehash 2>/dev/null
    function pyenv
        set command $argv[1]
        set -e argv[1]
        switch "$command"
            case rehash shell
                  source (pyenv "sh-$command" $argv|psub)
            case '*'
                command pyenv "$command" $argv
        end
    end
end

### Aliases
alias g "git"
alias gs "git status"
alias po "poetry"
alias pos "poetry shell"
alias por "poetry run"
alias popip "poetry run pip"

function p2sp
    set -l target (basename $argv[1] .pdf)
    echo "$target.pdf -> $target.svg"
    pdf2svg "$target.pdf" "$target.svg" $argv[2]
end
function p2s
    for filename in $argv
        set -l target (basename "$filename" .pdf)
        echo "$target.pdf -> $target.svg"
        pdf2svg "$target.pdf" "$target.svg"
    end
end

## pip install trasn-cli
if command -v trash >/dev/null
    alias rm "trash --trash-dir=$XDG_DATA_HOME/Trash -v"
else
    alias rm "rm -iv"
end
