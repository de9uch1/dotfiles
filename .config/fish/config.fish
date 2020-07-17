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
set -g theme_display_git yes
set -g theme_display_git_dirty no
set -g theme_display_git_untracked no
set -g theme_display_git_ahead_verbose yes
set -g theme_display_git_dirty_verbose yes
set -g theme_display_git_stashed_verbose yes
set -g theme_display_git_master_branch yes
set -g theme_git_worktree_support no
set -g theme_use_abbreviated_branch_name yes
set -g theme_display_vagrant yes
set -g theme_display_docker_machine no
set -g theme_display_k8s_context yes
set -g theme_display_hg yes
set -g theme_display_virtualenv no
set -g theme_display_nix no
set -g theme_display_ruby no
set -g theme_display_nvm yes
set -g theme_display_user yes
set -g theme_display_hostname yes
set -g theme_display_vi no
set -g theme_display_date yes
set -g theme_display_cmd_duration yes
set -g theme_title_display_process yes
set -g theme_title_display_path no
set -g theme_title_display_user yes
set -g theme_title_use_abbreviated_path no
set -g theme_date_format "+%a %H:%M"
set -g theme_date_timezone Asia/Tokyo
set -g theme_avoid_ambiguous_glyphs no
set -g theme_powerline_fonts yes
set -g theme_nerd_fonts no
set -g theme_show_exit_status yes
set -g theme_display_jobs_verbose yes
set -g default_user your_normal_user
set -g theme_color_scheme dracula
set -g fish_prompt_pwd_dir_length 0
set -g theme_project_dir_lengtsh 1
set -g theme_newline_cursor yes
set -g theme_newline_prompt ' '

# setup fisherman
if not [ -f $FISH_CONFIG_DIR/functions/fisher.fish ]
    echo "==> Fisherman not found. Installing..."
    curl -Lo $FISH_CONFIG_DIR/functions/fisher.fish --create-dirs git.io/fisher
    fisher
end

# enviroment variables
source $HOME/.envvars
set -gx GHQ_ROOT $HOME/src
set -g FZF_DEFAULT_OPTS "--height 30% --layout reverse --border --color 16"

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
