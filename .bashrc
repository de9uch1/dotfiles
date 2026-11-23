#!/usr/bin/env bash
# -*- mode:shell-script; sh-indentation:4; coding:utf-8 -*-

# Setup
if [[ -z "${LOADED_PROFILE}" ]]; then
    source "$HOME/.config/profile"
fi

# for non-interactive shell
if [[ $- != *i* ]]; then
    return
fi

export KERNEL_TYPE=$(uname)
export CPU_TYPE=$(uname -m)

# Prefix
if [[ $PREFIX_SYSTEM = gentoo ]] && [[ -d "${EPREFIX:-$HOME/gentoo}" ]]; then
    ## Gentoo prefix
    export EPREFIX="${EPREFIX:-$HOME/gentoo}"
    if [[ ${SHELL#"$EPREFIX"} = "$SHELL" ]] && [[ -f $HOME/bin/startprefix ]]; then
        exec "$HOME/bin/startprefix"
    fi
elif [[ $PREFIX_SYSTEM = brew ]] && [[ -d $HOME/.linuxbrew ]]; then
    ## linuxbrew
    echo "Entering brew..."
    export HOMEBREW_PREFIX="$HOME/.linuxbrew"
    export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
    export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin${PATH+:$PATH}"
    export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
fi

# Avoid executing fish shell in "dumb" TERM enviroment
if [[ $TERM = dumb ]] || [[ $TERM = eterm-color ]] || [[ $- = *c* ]]; then
    LOGIN_SHELL=bash
fi

# exec fish shell
if FISH_COMMAND=$(command -v fish) && \
        [[ -x "$FISH_COMMAND" ]] && \
        [[ "$LOGIN_SHELL" = "fish" ]]; then
    export SHLVL=$(( SHLVL - 1 ))
    SHELL="$FISH_COMMAND" PATH="$PATH" exec fish
fi

# aliases
if [[ $KERNEL_TYPE = Linux ]]; then
    alias ls='ls -F --color'
elif [[ $KERNEL_TYPE = FreeBSD ]]; then
    alias ls='ls -F -G'
fi
alias ll='ls -lh'
alias la='ls -a'
alias lla='ls -lha'
alias findn='find . -name'
alias duc='du -had1'
alias emacs='emacsclient -a "emacs"'
alias e='emacsclient -a "emacs"'

# Prompt
if command -v starship >/dev/null; then
    eval "$(starship init bash)"
fi

# for FreeBSD
if [[ $KERNEL_TYPE = FreeBSD ]]; then
    if [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
        source /usr/local/share/bash-completion/bash_completion
    fi
fi
