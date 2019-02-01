if [ $TERM = "dumb" ] ; or [ $TERM = "eterm-color" ]
    set -x SHELL (bash)
    exec bash
end

if [ -f {$HOME}/.config/fish/functions/powerline-setup.fish ]
    powerline-setup
    set -g theme_color_scheme solarized
end

# Setup Fisherman
if not [ -f {$HOME}/.config/fish/functions/fisher.fish ]
    echo "==> Fisherman not found. Installing..."
    curl -Lo {$HOME}/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
    fisher
end

# PATH
set -gx GOPATH {$HOME}/.go
if [ (uname -m) = "x86_64" ]
    set -l PATHs {$HOME}/opt/anaconda3/bin
end
set PATHs {$HOME}/bin {$HOME}/.gem/ruby/2.6.0/bin {$HOME}/.local/bin {$GOPATH}/bin {$PATHs}
for p in {$PATHs}
    if begin not contains {$p} {$PATH}; and test -e {$p}; end
        set -gx PATH {$p} {$PATH}
    end
end

# No Greeting
set fish_greeting

# Setting peco
function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
end

# on Gentoo System
if [ "$DISTRIB_ID""x" = "gentoox" ]
    gentoo-mode
end

# Alias
alias g "git"
