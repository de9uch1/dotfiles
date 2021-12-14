#/usr/bin/env fish
# -*- coding: utf-8; mode: fish -*-

set FISH_CONFIG_DIR $HOME/.config/fish

## Theme: Dracula
if not [ -f $FISH_CONFIG_DIR/conf.d/dracula.fish ]
    mkdir -p $FISH_CONFIG_DIR/conf.d
    curl -o $FISH_CONFIG_DIR/conf.d/dracula.fish \
        "https://raw.githubusercontent.com/dracula/fish/master/conf.d/dracula.fish"
end

## Disable Greeting
set fish_greeting

## Resets abbreviations list
set -g fish_user_abbreviations

## Prompt: Starship
if command -v starship >/dev/null
    starship init fish | source
end

## Plugin Manager: Fisher
set FISHER_INITIALIZED "$FISH_CONFIG_DIR/.fisher"
if not [ -f $FISHER_INITIALIZED ]
    echo "==> Fisher not found. Installing..."
    touch $FISHER_INITIALIZED
    curl -sL https://git.io/fisher | source; and fisher update
end

## Enviroment Variables
function reload_profile
    bass source $HOME/.config/profile
end
if [ -z "$LOADED_PROFILE" ]; and type -q bass
    reload_profile
end

## Basic Functions
function add_path
    set -l maybe_path $argv[1]
    if not contains $maybe_path $PATH
        set -gx PATH $maybe_path $PATH
    end
end

function err
    echo "$argv"
    return 1
end

## Manage Dotfiles
function dots
    set -l usage "usage: dots [u]"
    if [ (count $argv) != 1 ]
        err "$usage"
    end
    switch $argv[1]
        case u up update upgrade pull
            pushd ~/.dotfiles
            git pull
            make link
            popd
        case *
            err "$usage"
    end
end

## Gentoo System
if [ "{$DISTRIB_ID}x" = "gentoox" ]
    ### app-portage/portage-utils
    abbr -ag lastsync 'qlop -s | tail -n1'
    abbr -ag qtime    'qlop -tv'
    ### app-portage/flaggie
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

## Python
### pyenv
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

## Aliases / Abbreviations
### tmux
abbr -ag t     "tmux"
abbr -ag ta    "tmux attach -d"
### git
abbr -ag g     "git"
abbr -ag gs    "git status"
abbr -ag gco   "git checkout"
abbr -ag gl    "git log"
abbr -ag grs   "git reset --hard origin/(git branch --show-current)"
### poetry
abbr -ag po    "poetry"
abbr -ag pos   "poetry shell"
abbr -ag por   "poetry run"
abbr -ag popip "poetry run pip"
### ptpython
abbr -a -g pp    "ptpython"
### pdf2svg
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

## CLI tools
### enhancd
if type -q enhancd
    bind --erase \ef
    # set -g ENHANCD_HOOK_AFTER_CD "pwd; ls"
end
### lsd : ls : cargo install lsd
if command -v lsd >/dev/null
    alias ls     "lsd"
    abbr -ag l   "ls"
    abbr -ag ll  "ls -l"
    abbr -ag la  "ls -a"
    abbr -ag lla "ls -la"
end
### bat : cat : cargo install bat
if command -v bat >/dev/null
    alias cat  "bat"
    abbr -ag c "cat"
end
### git-delta : diff : cargo install git-delta
if command -v delta >/dev/null
    alias dif "delta"
    alias dlt "delta"
end
### trash-cli : rm : pip install trash-cli
if command -v trash >/dev/null; and [ $TRASH_DISABLED = 0 ]
    alias rm "trash --trash-dir=$XDG_DATA_HOME/Trash -v"
else
    alias rm "rm -iv"
end
### du-dust : du : cargo install du-dust
if command -v du-dust >/dev/null
    alias du "du-dust"
end

## Emacs
### vterm
function vterm_printf
    if begin; [  -n "$TMUX" ]  ; and  string match -q -r "screen|tmux" "$TERM"; end 
        # tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
    else if string match -q -- "screen*" "$TERM"
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$argv"
    else
        printf "\e]%s\e\\" "$argv"
    end
end
