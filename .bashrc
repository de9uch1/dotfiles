#!/usr/bin/env bash
# -*- mode:shell-script; sh-indentation:4; coding:utf-8 -*-

# for non-interactive shell
if [[ -z "${LOADED_PROFILE}" ]]; then
    source $HOME/.config/profile
fi

if [[ $- != *i* ]]; then
    return
fi

# for Gentoo Prefix
if [[ ${SHELL#$EPREFIX} = $SHELL ]] && [[ -f $EPREFIX/startprefix ]]; then
    exec $EPREFIX/startprefix
fi

# Avoid executing fish shell in "dumb" TERM enviroment
if [[ $TERM = dumb ]] || [[ $TERM = eterm-color ]]; then
    INTR_SHELL=bash
else
    INTR_SHELL=${INTR_SHELL:-fish}
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
alias mozc-wordregister="$EPREFIX/usr/lib/mozc/mozc_tool --mode=word_register_dialog"
alias emacs='emacsclient -a "emacs"'
alias e='emacsclient -a "emacs"'

# functions
function search() {
    w3m "http://google.com/search?q=$*"
}

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
