# -*- mode:shell-script; tab-width:4; coding:utf-8 -*-
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

################################################################
#### Enviroment Variables
################################################################
add-path(){
    while [ ${#} -gt 0 ] ; do
        if [ -d "${1}" ] && [[ ":${PATH}:" != *:"${1}":* ]] ; then
            export PATH="${1}:${PATH}"
        fi
        shift
    done
}

if [ -d ${HOME}/gentoo ] || [ -d ${HOME}/gentoo32 ] ; then
    if [ $(uname -m) = "x86_64" ] ; then
        EPREFIX=${HOME}/gentoo
    elif [ $(uname -m) = "i686" ] ; then
        EPREFIX=${HOME}/gentoo32
    fi
fi

export GOPATH="${HOME}/.go"
add-path ${HOME}/bin ${HOME}/.gem/ruby/2.6.0/bin
add-path ${HOME}/.local/bin ${GOPATH}/bin
add-path /usr/local/cuda/bin
if [ $(uname -m) = "x86_64" ] ; then
    add-path ${HOME}/opt/anaconda3/bin
fi

if [ "${TERM}" != "dumb" ] ; then
	export PS1="\[\033[01;36m\][\[\033[01;33m\]\u@\h\[\033[01;36m\]]-[\[\033[01;33m\]\$?\[\033[01;36m\]]-[\[\033[01;33m\]\w\[\033[01;36m\]]>\[\033[00m\] "
fi
export EMACS_SERVER_FILE="/tmp/emacs$(id -u)/server"
export HISTSIZE=10000000
export HISTCONTROL=ignoredups
stty stop undef
# Misc
if [ -z "${NOFISH}" ] ; then
    export NOFISH=0
fi
export QT_XFT="true"
export GDK_USE_XFT=1
export VDPAU_DRIVER="va_gl"

if [[ -f "${EPREFIX}/etc/os-release" ]] ;then
    source "${EPREFIX}/etc/os-release"
    export DISTRIB_ID="${ID}"
fi

################################################################
#### Aliases
################################################################
if [ $(uname) = "Linux" ] ; then
    alias ls='ls -F --color $*'
elif [ $(uname) = "FreeBSD" ] ; then
    alias ls='ls -F -G $*'
fi
alias ll='ls -lh $*'
alias la='ls -a $*'
alias lla='ls -lha $*'
alias findn='find . -name $*'
alias duc='du -had1 $*'
alias p='ps aux | grep $* | grep -v grep'
alias mozc-wordregister="${EPREFIX}/usr/lib/mozc/mozc_tool --mode=word_register_dialog"
alias emacs='emacsclient -a "emacs"'
alias e='emacsclient -a "emacs"'

################################################################
#### Functions
################################################################
search (){
    w3m "http://google.com/search?q=${*}"
}

################################################################
#### ThinkPad
################################################################
if [[ -e "/proc/acpi/ibm/fan" ]] ; then
    fanlevel() {
        echo "level $1" | sudo tee /proc/acpi/ibm/fan
    }
    alias stopfan='fanlevel 0'
	alias thermal='cat /proc/acpi/ibm/thermal | sed -e "s/ -128//g"'
fi

################################################################
#### ssh-agent
################################################################
start-ssh-agent() {
    if [ -f ${HOME}/.ssh-agent ] ; then
        source ${HOME}/.ssh-agent >/dev/null
    fi
    if [ -z "${SSH_AGENT_PID}" ] || ! kill -0 ${SSH_AGENT_PID}; then
        ssh-agent > ${HOME}/.ssh-agent
        source ${HOME}/.ssh-agent >/dev/null
    fi
    ssh-add -l >& /dev/null || ssh-add ${HOME}/.ssh/conf.d/vcs/id_rsa* >/dev/null 2>&1
}
if [ "${SERVER}x" != "1x" ] ; then
    start-ssh-agent
fi

################################################################
#### on FreeBSD
################################################################
if [ $(uname) = "FreeBSD" ] ; then
    [[ $PS1 && -f /usr/local/share/bash-completion/bash_completion ]] && \
        . /usr/local/share/bash-completion/bash_completion
fi

################################################################
#### on Gentoo System
################################################################
gentoo-mode(){
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
if [[ $DISTRIB_ID = "gentoo" ]] ;then
	gentoo-mode
fi

# Gentoo Prefix
if ! [ -z ${EPREFIX} ] && [ "${NOFISH}x" != "1x" ] && [ ${SHELL} != ${EPREFIX}/bin/bash ] && [ "${PS1}x" != "x" ] ; then
    if [[ ${SHELL#${EPREFIX}} != ${SHELL} ]] ; then
            echo "You appear to be in prefix already (SHELL=$SHELL)" > /dev/stderr
            exit -1
    fi

    SHELL=${SHELL##*/}
    export SHELL=${EPREFIX}/bin/${SHELL}
    if [[ ! -x $SHELL ]] ; then
            echo "Failed to find the Prefix shell, this is probably" > /dev/stderr
            echo "because you didn't emerge the shell ${SHELL##*/}" > /dev/stderr
            exit -1
    fi

    echo "Entering Gentoo Prefix ${EPREFIX}"
    RETAIN="HOME=$HOME TERM=$TERM USER=$USER SHELL=$SHELL NOFISH=$NOFISH PATH=$PATH TMUX_TMPDIR=/tmp"
    [[ -n ${PROFILEREAD} ]] && RETAIN+=" PROFILEREAD=$PROFILEREAD"
    [[ -n ${SSH_AUTH_SOCK} ]] && RETAIN+=" SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
    [[ -n ${DISPLAY} ]] && RETAIN+=" DISPLAY=$DISPLAY"
    exec env -i $RETAIN $SHELL -l

    echo "Leaving Gentoo Prefix with exit status $?"
fi

################################################################
#### fish loader
################################################################
if [ ${TERM} = "dumb" ] || [ ${TERM} = "eterm-color" ] ; then
    NOFISH=1
fi

if [ ${NOFISH} = 0 ] && [ $(which fish) ] ; then
    [ -x ${EPREFIX}/bin/fish ] && SHELL=${EPREFIX}/bin/fish PATH=$PATH exec ${EPREFIX}/bin/fish
fi
