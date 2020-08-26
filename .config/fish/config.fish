# -*- mode: fish -*-

set FISH_CONFIG_DIR $HOME/.config/fish

# for non-interactive shell
# if [ $TERM = "dumb" ] || [ $TERM = "eterm-color" ]
#     set -x SHELL (which bash)
#     exec bash
# end

# Theme
if ! [ -f $FISH_CONFIG_DIR/conf.d/dracula.fish ]
    mkdir -p $FISH_CONFIG_DIR/conf.d
    curl -o $FISH_CONFIG_DIR/conf.d/dracula.fish \
        "https://raw.githubusercontent.com/dracula/fish/master/conf.d/dracula.fish"
end

# Dracula Theme
set -g theme_display_git yes
set -g theme_git_worktree_support no
set -g theme_use_abbreviated_branch_name no
set -g theme_display_user yes
set -g theme_display_hostname yes
set -g theme_display_date yes
set -g theme_date_format "+%Y/%m/%d (%a) %H:%M:%S"
set -g theme_date_timezone Asia/Tokyo
set -g theme_avoid_ambiguous_glyphs no
set -g theme_powerline_fonts yes
set -g theme_nerd_fonts no
set -g theme_color_scheme dracula
set -g fish_prompt_pwd_dir_length 0
set -g theme_project_dir_length 0
set -g theme_newline_cursor yes

# setup fisherman
if not functions -q fisher
    echo "==> Fisher not found. Installing..."
    curl -sLo https://git.io/fisher --create-dirs $FISH_CONFIG_DIR/functions/fisher.fish
    fish -c fisher
end

# enhancd
set -gx ENHANCD_ROOT $HOME/.cache/fisher/github.com/b4b4r07/enhancd

# enviroment variables
if [ -z "$LOADED_PROFILE" ]; and type -q bass
    bass source $HOME/.config/profile
end

# my functions
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

# dotfiles
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

# for Gentoo
if [ "{$DISTRIB_ID}x" = "gentoox" ]
    gentoo-mode
end

# Python
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

# alias
alias g "git"

# for experiments
if command -v xp >/dev/null && [ -n $FILTER ]
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
