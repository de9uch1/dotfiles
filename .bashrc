#!/bin/bash
# -*- mode:shell-script; sh-indentation:4; coding:utf-8 -*-

# for non-interactive shell
if [[ $- != *i* ]]; then
	return
fi

# aliases
if [[ $(uname) = Linux ]]; then
    alias ls='ls -F --color $*'
elif [[ $(uname) = FreeBSD ]]; then
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
function search (){
    w3m "http://google.com/search?q=$*"
}

# for ThinkPad
if [[ -e /proc/acpi/ibm/fan ]]; then
    function fanlevel() {
        echo "level $1" | sudo tee /proc/acpi/ibm/fan
    }
    alias stopfan='fanlevel 0'
	alias thermal='cat /proc/acpi/ibm/thermal | sed -e "s/ -128//g"'
fi

# ssh-agent
function start-ssh-agent() {
    if [[ -f $HOME/.ssh-agent ]]; then
        source $HOME/.ssh-agent >/dev/null
    fi
    if [[ -z $SSH_AGENT_PID ]] || ! kill -0 $SSH_AGENT_PID; then
        ssh-agent > $HOME/.ssh-agent
        source $HOME/.ssh-agent >/dev/null
    fi
    ssh-add -l >& /dev/null || ssh-add $HOME/.ssh/conf.d/vcs/id_rsa* >/dev/null 2>&1
}
[[ $SERVER != 1 ]] && start-ssh-agent

# for FreeBSD
if [[ $(uname) = FreeBSD ]]; then
    [[ $PS1 && -f /usr/local/share/bash-completion/bash_completion ]] && \
        source /usr/local/share/bash-completion/bash_completion
fi

# for Gentoo
function gentoo-mode(){
	# app-portage/portage-utils
	alias lastsync='qlop -s | tail -n1'
	alias qtime='qlop -tHvg'

	# app-portage/eix
	diffup() {
		sudo emerge -au1 $(eix-diff | awk '/^\[.?U\]/ {print $3}' | xargs)
	}

	# app-portage/flaggie
	acckw() {
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
				return 1
		esac
	}
	return 0
}

[[ $DISTRIB_ID = gentoo ]] && gentoo-mode

# Gentoo Prefix
if ! [[ -z $EPREFIX ]] && [[ $NOFISH != 1 ]] && [[ $SHELL != $EPREFIX/bin/bash ]] && ! [[ -z $PS1 ]]; then
    SHELL=/bin/bash

    if [[ ${SHELL#${EPREFIX}} != ${SHELL} ]]; then
            echo "You appear to be in prefix already (SHELL=$SHELL)" > /dev/stderr
            exit -1
    fi

    SHELL=${SHELL##*/}
    export SHELL=${EPREFIX}/bin/${SHELL}
    if [[ ! -x $SHELL ]]; then
            echo "Failed to find the Prefix shell, this is probably" > /dev/stderr
            echo "because you didn't emerge the shell ${SHELL##*/}" > /dev/stderr
            exit -1
    fi

    echo "Entering Gentoo Prefix ${EPREFIX}"
    RETAIN="HOME=$HOME TERM=$TERM USER=$USER SHELL=$SHELL NOFISH=$NOFISH PATH=$PATH TMUX_TMPDIR=/tmp"
    [[ -n ${PROFILEREAD} ]] && RETAIN+=" PROFILEREAD=$PROFILEREAD"
    [[ -n ${SSH_AUTH_SOCK} ]] && RETAIN+=" SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
    [[ -n ${DISPLAY} ]] && RETAIN+=" DISPLAY=$DISPLAY"
    # exec env -i $RETAIN $SHELL -l
    exec $SHELL -l

    echo "Leaving Gentoo Prefix with exit status $?"
fi

# for fish shell
if [[ $TERM = dumb ]] || [[ $TERM = eterm-color ]]; then
    NOFISH=1
fi
[[ $NOFISH = 0 ]] && $(which fish >/dev/null 2>&1) && [[ -x $EPREFIX/bin/fish ]] && \
  SHELL=$EPREFIX/bin/fish PATH=$PATH exec $EPREFIX/bin/fish
