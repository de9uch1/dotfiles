#!/bin/bash
# -*- mode:shell-script; sh-indentation:4; coding:utf-8 -*-

function add_path() {
    while [[ $# -gt 0 ]] ; do
        if [[ -d "$1" ]] && [[ ":${PATH}:" != *:"$1":* ]] ; then
            export PATH="${1}:${PATH}"
        fi
        shift
    done
}

# enviroment variables
source $HOME/.envvars

export LANG=ja_JP.UTF-8
export SERVER=1
[[ -d $HOME/gentoo ]] && [[ $(uname -m) = x86_64 ]] && EPREFIX=$HOME/gentoo
[[ -d $HOME/gentoo32 ]] && [[ $(uname -m) = i686 ]] && EPREFIX=$HOME/gentoo32
[[ $TERM != dumb ]] && export PS1="\[\033[01;36m\][\[\033[01;33m\]\u@\h\[\033[01;36m\]]-[\[\033[01;33m\]\$?\[\033[01;36m\]]-[\[\033[01;33m\]\w\[\033[01;36m\]]>\[\033[00m\] "
export EMACS_SERVER_FILE=/tmp/emacs$(id -u)/server
export HISTSIZE=10000000
export HISTCONTROL=ignoredups
[[ $- = *i* ]] && stty stop undef
[[ -z $NOFISH ]] && export NOFISH=0
export QT_XFT="true"
export GDK_USE_XFT=1
export VDPAU_DRIVER="va_gl"
if [[ -f $EPREFIX/etc/os-release ]]; then
    source $EPREFIX/etc/os-release
    export DISTRIB_ID="${ID}"
fi

# programming languages specific PATH
export GOPATH=$HOME/.go
add_path $GOPATH/bin
if $(which ruby >/dev/null 2>&1); then
    add_path $(ruby -e 'puts Gem.user_dir')/bin
fi
if [[ $(uname -m) = "x86_64" ]] ; then
    add_path $HOME/opt/anaconda3/bin
fi
add_path /usr/local/cuda/bin

# my scripts and own tools
add_path $HOME/bin
add_path $HOME/.local/bin
add_path $HOME/local/bin

# for experiments
add_path $HOME/src/github.com/de9uch1/mlenv/bin
add_path $HOME/src/github.com/de9uch1/MiniBatch/bin
add_path $HOME/src/github.com/de9uch1/Xplorer/bin
add_path $HOME/exp/scripts
if [[ -f $HOME/exp/.profile ]]; then
    source $HOME/exp/.profile
    alias d="pushd $HOME/exp/data"
fi

# interactive filtering tool
which peco >/dev/null 2>&1 && export FILTER="peco --layout bottom-up --on-cancel error"

# load ~/.bashrc
if [[ -f ~/.bashrc ]] ; then
    source ~/.bashrc
fi
