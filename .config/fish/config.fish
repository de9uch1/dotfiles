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
source $HOME/.envvars
set -gx GHQ_ROOT $HOME/src
set -gx GHQ_SELECTOR fzf
set -gx FZF_DEFAULT_OPTS "--height 30% --layout reverse --border --color 16"
set -U FZF_LEGACY_KEYBINDINGS 0

# Golang
set -gx GOPATH $HOME/.go
function add_path
    set -l maybe_path $argv[1]
    if not contains $maybe_path $PATH
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
