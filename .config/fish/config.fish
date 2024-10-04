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

## History
set -x CMDLOG_HISTORY_FILE $HOME/.cmdlog_history
set -x DISABLE_CMDLOG_HISTORY
set -x CMDLOG_IGNORES cmdlogger pdh pdha pdr
function __perdir_history_save --on-event fish_preexec
    cmdlogger -a "$argv"
end
function __perdir_history_fzf_reverse_isearch
    cmdlogger -l \
        | eval (__fzfcmd) --tiebreak=index --print0 --read0 --toggle-sort=alt-r $FZF_DEFAULT_OPTS $FZF_REVERSE_ISEARCH_OPTS -q '(commandline)' \
        | read -zl result
    and commandline -- $result
    commandline -f repaint
end
bind \er '__perdir_history_fzf_reverse_isearch'
alias pdh  "cmdlogger -u"
alias pdha "cmdlogger -p"
alias pdr  "cmdlogger -a"

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

function __yank
    for i in (seq (count $fish_killring))
        echo $fish_killring[$i]
    end | fzf --print0 \
        | read -lz result
    and commandline -- $result
    commandline -f repaint
end
bind \ey "__yank"

function __ssh
    set -l hosts_file $HOME/.ssh/hosts
    [ -f $hosts_file ]; or return
    fzf --print0 < $hosts_file \
        | read -lz result
    [ -n "$result" ]; and ssh $result
    commandline -f repaint
end
bind \es "__ssh"

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
### UNIX commands
alias df       "df -Th"
alias free     "free -h"
abbr -ag se    "ssh -O exit"
alias m        "make"
alias parallel "parallel --gnu"
alias p        "parallel"
abbr -ag p     "parallel"
if command -v pigz >/dev/null
    alias gzip "pigz"
end
### My functions
alias ncpus "nproc"
alias ngpus "nvidia-smi --query-gpu=index --format=csv,noheader,nounits | wc -l"
### My research tools
#### mlexp
alias ml    "mlexp"
alias grun  "mlexp gpu poll"
alias mlr   "mlexp run"
alias mlrm  "mlexp rm"
alias mls   "mlexp list -v"
alias mll   "mlexp log"
alias mlsh  "mlexp show"
abbr -ag mr "mlexp run -- mrun"
#### nlpack
alias analyzer        "nlpack analyzer"
alias corpus-stats    "analyzer corpus-stats"
alias compare-sysouts "analyzer compare-sysouts"
alias show-aligns     "analyzer show-aligns"
### tmux
abbr -ag t     "tmux"
abbr -ag ta    "tmux attach -d"
### git
abbr -ag g     "git"
abbr -ag gs    "git status"
abbr -ag gco   "git checkout"
abbr -ag gl    "git log"
abbr -ag grs   "git reset --hard origin/(git branch --show-current)"
abbr -ag gpl   "git pull"
abbr -ag gps   "git push"
abbr -ag gf    "git fetch"
abbr -ag gfr   "git fetch && git reset --hard origin/(git branch --show-current)"
### poetry
abbr -ag po    "poetry"
abbr -ag poi   "poetry install"
abbr -ag pou   "poetry update"
abbr -ag pos   "poetry shell"
abbr -ag por   "poetry run"
abbr -ag popip "poetry run pip"
### rye
# alias pys      "fish -il --init-command='source (rye show | grep \'^venv: \' | sed -e \'s/^venv: //g\')/bin/activate.fish'"
function pys
    set -l curdir (pwd)
    set -l prevdir ""
    while [ "$curdir" != "$prevdir" ]; and [ "$curdir" != "/" ]
        if [ -d "$curdir/.venv" ]
            fish -il --init-command="source '$curdir/.venv/bin/activate.fish'"
            break
        end
        set prevdir "$curdir"
        set curdir (realpath "$curdir/../")
    end
end

### ptpython
alias pp       "ptpython --history (git root 2>/dev/null; or echo .)/.ptpython_history"
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
    alias ls   "lsd"
    alias l    "ls"
    alias ll   "ls -l"
    alias la   "ls -a"
    alias lla  "ls -la"
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
if command -v dust >/dev/null
    alias du     "dust --terminal_width 80"
    abbr -ag du1 "du -d 1"
    abbr -ag du2 "du -d 2"
end
### csview : : cargo install csview
if command -v csview >/dev/null
    alias tsview "command csview -t -s Rounded"
    alias csview "command csview -s Rounded"
end
## direnv
if command -v direnv >/dev/null
    direnv hook fish | source
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
