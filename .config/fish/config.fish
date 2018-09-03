if [ $TERM = "dumb" ]
    set -x SHELL (bash)
    exec bash
end

# Setup Fisherman
if not [ -f {$HOME}/.config/fish/functions/fisher.fish ]
    echo "==> Fisherman not found. Installing..."
    curl -Lo {$HOME}/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
    fisher
end

# PATH
set -gx GOPATH {$HOME}/.go
set -l PATHs {$HOME}/bin {$HOME}/.gem/ruby/2.5.0/bin {$HOME}/.local/bin {$HOME}/opt/anaconda3/bin {$GOPATH}/bin
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
