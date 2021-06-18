#!/usr/bin/env bash
# -*- mode:shell-script; sh-indentation:4; coding:utf-8 -*-

if [[ -z "${LOADED_PROFILE}" ]]; then
    source $HOME/.config/profile
fi

# for non-interactive shell
if [[ $- != *i* ]]; then
    return
fi

export KERNEL_TYPE=$(uname)
export CPU_TYPE=$(uname -m)

### Gentoo system
if [[ $PREFIX_SYSTEM = gentoo ]] && \
       [[ -d $HOME/gentoo ]] && \
       [[ $CPU_TYPE = x86_64 ]]; then
    export EPREFIX=$(realpath $HOME/gentoo)
fi
if [[ $PREFIX_SYSTEM = gentoo ]] && \
       [[ ${SHELL#$EPREFIX} = $SHELL ]] && \
       [[ -f $EPREFIX/startprefix ]]; then
    exec $EPREFIX/startprefix
    if [[ -f $EPREFIX/etc/os-release ]]; then
        source $EPREFIX/etc/os-release
        export DISTRIB_ID="${ID}"
    fi
fi

### linuxbrew
if [[ $PREFIX_SYSTEM = brew ]] && \
       [[ -d $HOME/.linuxbrew ]] && \
       [[ $CPU_TYPE = x86_64 ]]; then
    echo "Entering brew..."
    export HOMEBREW_PREFIX="$HOME/.linuxbrew"
    export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
    export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin${PATH+:$PATH}"
    export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
fi

# Avoid executing fish shell in "dumb" TERM enviroment
export INTR_SHELL=${INTR_SHELL:-fish}
if [[ $TERM = dumb ]] || [[ $TERM = eterm-color ]]; then
    INTR_SHELL=bash
fi

# exec fish shell
if FISH_COMMAND=$(command -v fish) && \
        [[ -x "$FISH_COMMAND" ]] && \
        [[ "$INTR_SHELL" = "fish" ]]; then
    SHELL="$FISH_COMMAND" PATH="$PATH" exec fish
fi

# aliases
if [[ $KERNEL_TYPE = Linux ]]; then
    alias ls='ls -F --color $*'
elif [[ $KERNEL_TYPE = FreeBSD ]]; then
    alias ls='ls -F -G $*'
fi
alias ll='ls -lh $*'
alias la='ls -a $*'
alias lla='ls -lha $*'
alias findn='find . -name $*'
alias duc='du -had1 $*'
alias p='ps aux | grep $* | grep -v grep'
alias emacs='emacsclient -a "emacs"'
alias e='emacsclient -a "emacs"'

# Prompt
if command -v starship >/dev/null; then
    eval "$(starship init bash)"
fi

# Python
if command -v pyenv >/dev/null; then
    export PYENV_SHELL=bash
    source "$PYENV_ROOT/libexec/../completions/pyenv.bash"
    command pyenv rehash 2>/dev/null
    function pyenv() {
        local command
        command="${1:-}"
        if [ "$#" -gt 0 ]; then
            shift
        fi

        case "$command" in
            rehash|shell)
                eval "$(pyenv "sh-$command" "$@")";;
            *)
                command pyenv "$command" "$@";;
        esac
    }
fi

# for FreeBSD
if [[ $KERNEL_TYPE = FreeBSD ]]; then
    [[ $PS1 && -f /usr/local/share/bash-completion/bash_completion ]] && \
        source /usr/local/share/bash-completion/bash_completion
fi

# for Gentoo system
function gentoo-mode(){
	# app-portage/portage-utils
	alias lastsync='qlop -s | tail -n1'
	alias qtime='qlop -tv'

	# app-portage/flaggie
	function acckw() {
		case $1 in
			a)
				sudo flaggie $2 '+kw::~amd64'
				;;
			d)
				sudo flaggie $2 '-kw::~amd64'
				;;
			r)
				sudo flaggie $2 '%kw::~amd64'
				;;
			v)
				sudo flaggie $2 '?kw::~amd64'
				;;
			*)
				return -1
		esac
	}
}
[[ $DISTRIB_ID = gentoo ]] && gentoo-mode
